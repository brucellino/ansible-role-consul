#!/bin/env bash
set -eo pipefail
# Script for installng Ansible in a virtualenv
mkdir -p /opt/consul/scripts/ansible-bootstrap
cd /opt/consul/scripts/ansible-bootstrap
./yq || curl -fSL https://github.com/mikefarah/yq/releases/download/v4.30.6/yq_linux_arm64 > yq
chmod u+x yq
consul kv get hashiatho.me/step-up/bootstrap | ./yq -r '.script' > script.sh
chmod u+x script.sh
rm -rvf virtualenv-ansible-bootstrap
virtualenv virtualenv-ansible-bootstrap
source virtualenv-ansible-bootstrap/bin/activate
consul kv get hashiatho.me/step-up/bootstrap | ./yq -r '.requirements' > requirements.txt
pip install -r requirements.txt
ansible --version
