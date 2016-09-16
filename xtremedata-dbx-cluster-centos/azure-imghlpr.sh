#!/bin/bash

[[ -z "$HOME" || ! -d "$HOME" ]] && { echo 'fixing $HOME'; HOME=/root; }
export HOME

yum install -y epel-release
yum install -y nodejs
yum install -y npm
npm install -g azure-cli
azure config mode arm

export AZURE_STORAGE_ACCOUNT="$1"
export AZURE_STORAGE_ACCESS_KEY="$2"

azure storage container create img
azure storage blob copy start --source-uri="$3" --dest-container img --dest-blob os-disk-img.vhd
logger -t imghelper "copy started: $?"

rr=1
while [ $rr -ne 0 ]; do
  sleep 10
  azure storage blob copy show --json img os-disk-img.vhd | grep '"copyStatus": "success"' >/dev/null
  # "copyStatus": "success",  "copyStatus": "pending"
  rr=$?
done

logger -t imghelper "success"
exit 0
