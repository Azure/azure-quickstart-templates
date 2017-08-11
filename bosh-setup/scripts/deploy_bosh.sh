#!/usr/bin/env bash

set -e

export BOSH_INIT_LOG_LEVEL="Debug"
export BOSH_INIT_LOG_PATH="./run.log"
bosh-init deploy ~/bosh.yml

bosh target REPLACE_WITH_BOSH_DIRECOT_IP >/dev/null 2>&1 << EndOfMessage
admin
REPLACE_WITH_ADMIN_PASSWORD
EndOfMessage

if [ -e ~/example_manifests/single-vm-cf.yml ]; then
  sed -i -e "s/REPLACE_WITH_DIRECTOR_UUID/$(bosh status --uuid)/" ~/example_manifests/single-vm-cf.yml
fi
if [ -e ~/example_manifests/multiple-vm-cf.yml ]; then
  sed -i -e "s/REPLACE_WITH_DIRECTOR_UUID/$(bosh status --uuid)/" ~/example_manifests/multiple-vm-cf.yml
fi
