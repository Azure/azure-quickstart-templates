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

