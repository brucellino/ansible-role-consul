packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "v1.0.3"
    }
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "v1.0.5"
    }
    arm = {
      source  = "github.com/cdecoux/builder-arm"
      version = "1.0.0"
    }
  }
  required_version = ">=1.7.0, <2.0.0"
}

variable "roles_path" {
  type = string
}

variable "docker_password" {
  type      = string
  sensitive = true
  default   = env("GITHUB_TOKEN")
}

locals {
  docker_registry = "ghcr.io/brucellino/ansible-role-consul"
}

variable "tag_version" {
  type      = string
  sensitive = false
  default   = "latest"
}

variable "raspi_image_size" {
  description = "Size of the raspberry pi disk image"
  type        = string
  default     = "10GB"
}

source "arm" "raspi-os-64" {
  file_urls             = ["https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-04-07/2022-04-04-raspios-bullseye-arm64.img.xz"]
  file_checksum_url     = "https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-04-07/2022-04-04-raspios-bullseye-arm64.img.xz.sha256"
  file_checksum_type    = "sha256"
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  image_build_method    = "reuse"
  image_path            = "raspios-bullseye.img"
  image_size            = var.raspi_image_size
  image_type            = "dos"
  image_mount_path = "/tmp/rpi_chroot/"
  image_partitions {
    name         = "boot"
    type         = "c"
    start_sector = "2048"
    filesystem   = "fat"
    size         = "256M"
    mountpoint   = "/boot/firmware"
  }
  image_partitions {
    name         = "root"
    type         = "83"
    start_sector = "526336"
    filesystem   = "ext4"
    size         = "0"
    mountpoint   = "/"
  }

  image_chroot_env             = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  qemu_binary_source_path      = "/usr/bin/qemu-aarch64-static"
  qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
}


source "docker" "ubuntu-arm64" {
  image     = "arm64v8/ubuntu:focal"
  commit    = true
  exec_user = "root"
  changes = [
    "USER root",
    "LABEL VERSION=latest",
    "LABEL org.opencontainers.image.source https://github.com/brucellino/ansible-role-consul",
    "ENTRYPOINT /entrypoint.sh"

  ]
  run_command = [
    "-d", "-i", "-t", "--entrypoint=/bin/bash",
    "--name=ubuntu-consul-arm64",
    "--", "{{ .Image }}"
  ]
}

source "docker" "ubuntu-amd64" {
  image     = "ubuntu:focal"
  commit    = true
  exec_user = "root"
  changes = [
    "USER root",
    "LABEL VERSION=latest",
    "LABEL org.opencontainers.image.source https://github.com/brucellino/ansible-role-consul",
    "ENTRYPOINT /entrypoint.sh"
  ]
  run_command = [
    "-d", "-i", "-t", "--entrypoint=/bin/bash",
    "--name=ubuntu-consul-amd64",
    "--", "{{ .Image }}"
  ]
}

build {
  name = "consul"
  sources = [
    "source.docker.ubuntu-arm64",
    "source.docker.ubuntu-amd64",
    "source.arm.raspi-os-64"
  ]

  provisioner "ansible" {
    playbook_file = "playbook.yml"
    groups        = ["pis"]
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'",
      "ANSIBLE_NOCOLOR=True",
      "ANSIBLE_ROLES_PATH=${var.roles_path}",
      "ANSIBLE_CONNECTION=docker"
    ]
    only = ["docker.ubuntu-arm64", "docker.ubuntu-amd64"]
  }

  provisioner "ansible" {
    inventory_file_template = "default ansible_host=/tmp/rpi_chroot ansible_connection=chroot"
    extra_arguments = [
      "--connection=chroot"
    ]
    playbook_file = "playbook.yml"
    groups        = ["all"]
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'",
      "ANSIBLE_NOCOLOR=True",
      "ANSIBLE_ROLES_PATH=${var.roles_path}"
    ]
    only = ["arm.raspi-os-64"]
  }

  post-processors {
    # Get Trivy
    post-processor "shell-local" {
      inline = [
        "curl -Lf https://github.com/aquasecurity/trivy/releases/download/v0.35.0/trivy_0.35.0_Linux-64bit.tar.gz | tar xz trivy"
      ]
      only = ["docker.ubuntu-arm64", "docker.ubuntu-amd64"]
    }

    post-processor "docker-tag" {
      repository = "${local.docker_registry}/consul-ubuntu-amd64"
      tags       = [var.tag_version]
      only       = ["docker.ubuntu-amd64"]
    }
    post-processor "shell-local" {
      inline = [
        "./trivy image -s CRITICAL,HIGH --exit-code 0 --format github --ignore-unfixed ${local.docker_registry}/consul-ubuntu-amd64:${var.tag_version}"
      ]
      only = ["docker.ubuntu-amd64"]
    }
    post-processor "docker-tag" {
      repository = "${local.docker_registry}/consul-ubuntu-arm64"
      tags       = [var.tag_version]
      only       = ["docker.ubuntu-arm64"]
    }

    post-processor "shell-local" {
      inline = [
        "./trivy image -s CRITICAL,HIGH --exit-code 0 --format github --ignore-unfixed ${local.docker_registry}/consul-ubuntu-arm64:${var.tag_version}"
      ]
      only = ["docker.ubuntu-arm64"]
    }

    post-processor "docker-push" {
      login          = true
      login_server   = "https://ghcr.io"
      login_username = "brucellino"
      login_password = var.docker_password
      only = ["docker.ubuntu-arm64", "docker.ubuntu-amd64"]
    }
  }
}
