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
  name = "docker-ubuntu"
  sources = [
    "source.docker.ubuntu-arm64",
    "source.docker.ubuntu-amd64"
  ]

  provisioner "ansible" {
    playbook_file = "playbook.yml"
    groups        = ["pis"]
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'",
      "ANSIBLE_NOCOLOR=True",
      "ANSIBLE_ROLES_PATH=${var.roles_path}"
    ]
  }

  post-processors {
    # Get Trivy
    post-processor "shell-local" {
      inline = [
        "curl -Lf https://github.com/aquasecurity/trivy/releases/download/v0.30.0/trivy_0.30.0_Linux-64bit.tar.gz | tar xz trivy"
      ]
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
    }
  }
}
