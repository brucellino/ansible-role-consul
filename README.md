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
3. Consul TLS and gossip secrets  read from Vault

## Requirements

<!-- Any pre-requisites that may not be covered by Ansible itself or the role should
be mentioned here. For instance, if the role uses the EC2 module, it may be a
good idea to mention in this section that the boto package is required. -->
This role requires a working Vault instance with TLS secrets and gossip keys in a given path.

## Role Variables

<!-- A description of the settable variables for this role should go here, including
any variables that are in defaults/main.yml, vars/main.yml, and any variables
that can/should be set via parameters to the role. Any variables that are read
from other roles and/or the global scope (ie. hostvars, group vars, etc.) should
be mentioned here as well. -->

See [`defaults/main.yml`](defaults/main.yml) for default variables

## Dependencies

<!-- A list of other roles hosted on Galaxy should go here, plus any details in
regards to parameters that may need to be set for other roles, or variables that
are used from other roles. -->
No dependencies on other roles.

## Example Playbook

For an example playbook see `.github/build/playbook.yml`

## License

MIT

## Author Information

<!-- An optional section for the role authors to include contact information, or a
website (HTML is not allowed). -->
@brucellino <bruce.becker@proton.me>
