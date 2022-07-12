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

variable "ansible_roles_path" {
  type    = string
  default = env("GITHUB_WORKSPACE")
}

source "docker" "ubuntu" {
  image     = "arm64v8/ubuntu:focal"
  commit    = true
  exec_user = "root"
  changes = [
    "USER root",
    "LABEL VERSION=latest"
  ]
  run_command = [
    "-d", "-i", "-t", "--entrypoint=/bin/bash",
    "--name=ubuntu-consul",
    "--", "{{ .Image }}"
  ]
}

build {
  name    = "docker-ubuntu"
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    inline = ["touch /tmp/hello"]
  }

  provisioner "ansible" {
    playbook_file = "consul.yml"
    groups        = ["pis"]
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'",
      "ANSIBLE_NOCOLOR=True",
      "ANSIBLE_ROLES_PATH=${var.ansible_roles_path}"
    ]
  }
}
