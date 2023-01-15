[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/brucellino/ansible-role-consul/main.svg)](https://results.pre-commit.ci/latest/github/brucellino/ansible-role-consul/main) [![main](https://github.com/brucellino/ansible-role-consul/actions/workflows/main.yml/badge.svg)](https://github.com/brucellino/ansible-role-consul/actions/workflows/main.yml) [![semantic-release: angular](https://img.shields.io/badge/semantic--release-conventional-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

# Ansible role Consul

<!-- A brief description of the role goes here. -->
An Ansible role to deploy [Hashicorp Consul](https://consul.io) on supported platforms, following the [Datacenter deploy guide](https://learn.hashicorp.com/tutorials/consul/deployment-guide?in=consul/production-deploy).
This role is intended to provision a base image configured to provision the Consul security assets (gossip key and CA) from a secure storage in a Vault instance.

Using this role you can provision an image for a server and agent respectively, and then use those images to launch instances to bootstrap the cluster and auto join nodes.

## Features

This role provisions:

1. Consul itself, agent and server mode
2. Other necessary tools (`consul-template`, `vault`)
3. Consul TLS and gossip secrets read from Vault

The role is designed to use vault agent to template the consul configuration files.

There is experimental support for joining wifi networks.

## Requirements

This role requires a working Vault instance with TLS secrets and gossip keys in a given path.
Machines are configured to authenticate to Vault with an Approle Role ID.

This role can be applied to virtual machines, physical machines and docker containers.
Support for OCI containers will come as soon as I can figure out a reliable way of detecting whether we are in an arbitrary kind of container.

<!--
Could either use /.dockerenv or /.containerenv or docker in /proc/1/cgroup
See https://stackoverflow.com/questions/23513045/how-to-check-if-a-process-is-running-inside-docker-container
 -->

## Role Variables

See [`defaults/main.yml`](defaults/main.yml) for default variables.

## Dependencies

No dependencies on other roles.

## Example Playbook

For an example playbook see `.github/build/playbook.yml`.
An example Packer template which builds the images is in `.github/build/consul.pkr.hcl`.

## License

MIT

## Author Information

@brucellino <brucellino@proton.me>
