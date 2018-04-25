#!/usr/bin/env bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: ./update-china-storage-account.sh <template-version>. For example: ./update-china-storage-account.sh v1-0-0"
    exit 1
fi

set -e

# The template version should be same as variables('templateVersion') in azuredeploy.json
template_version="$1"
container_name="bosh-setup"
directories="scripts manifests"
for directory in $directories; do
  for file in $directory/*; do
    if [[ -f $file ]]; then
      azure storage blob upload $file ${container_name} ${template_version}/$file
    fi
  done
done

bosh_cli_version="2.0.48"
bosh_cli_name="bosh-cli-${bosh_cli_version}-linux-amd64"
wget https://s3.amazonaws.com/bosh-cli-artifacts/${bosh_cli_name} -O /tmp/${bosh_cli_name}
azure storage blob upload /tmp/${bosh_cli_name} ${container_name} bosh-cli/${bosh_cli_name} --quiet

cf_cli_version="6.34.1"
cf_cli_name="cf-cli-installer_${cf_cli_version}_x86-64.deb"
wget https://s3-us-west-1.amazonaws.com/cf-cli-releases/releases/v${cf_cli_version}/${cf_cli_name} -O /tmp/${cf_cli_name}
azure storage blob upload /tmp/${cf_cli_name} ${container_name} cf-cli/${cf_cli_name} --quiet
