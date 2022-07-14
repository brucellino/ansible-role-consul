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

source "docker" "ubuntu-arm64" {
  image     = "arm64v8/ubuntu:focal"
  commit    = true
  exec_user = "root"
  changes = [
    "USER root",
    "LABEL VERSION=latest",
    "LABEL org.opencontainers.image.source https://github.com/brucellino/ansible-role-consul"
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
    "LABEL org.opencontainers.image.source https://github.com/brucellino/ansible-role-consul"
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
    post-processor "docker-tag" {
      repository = "ghcr.io/brucellino/consul-ubuntu-amd64"
      tags       = ["latest"]
      only       = ["docker.ubuntu-amd64"]
    }
    post-processor "docker-tag" {
      repository = "ghcr.io/brucellino/consul-ubuntu-amd64"
      tags       = ["latest"]
      only       = ["docker.ubuntu-arm64"]
    }
    post-processor "docker-push" {
      login          = true
      login_server   = "https://ghcr.io"
      login_username = "brucellino"
      login_password = var.docker_password
    }
  }
}
