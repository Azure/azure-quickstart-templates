#!/usr/bin/env bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: ./update-china-storage-account.sh <template-version>. For example: ./update-china-storage-account.sh v1-0-0"
    exit 1
fi

set -e

# The template version should be same as variables('templateVersion') in azuredeploy.json
template_version="$1"
container_name="bosh-setup"

azure storage blob upload scripts/create_cert.sh ${container_name} ${template_version}/scripts/create_cert.sh --quiet
azure storage blob upload scripts/deploy_bosh.sh ${container_name} ${template_version}/scripts/deploy_bosh.sh --quiet
azure storage blob upload scripts/deploy_cloudfoundry.sh ${container_name} ${template_version}/scripts/deploy_cloudfoundry.sh --quiet
azure storage blob upload scripts/inject_xip_io_records.py ${container_name} ${template_version}/scripts/inject_xip_io_records.py --quiet
azure storage blob upload scripts/init.sh ${container_name} ${template_version}/scripts/init.sh --quiet
azure storage blob upload scripts/setup_env ${container_name} ${template_version}/scripts/setup_env --quiet
azure storage blob upload scripts/setup_env.py ${container_name} ${template_version}/scripts/setup_env.py --quiet
azure storage blob upload manifests/bosh.yml ${container_name} ${template_version}/manifests/bosh.yml --quiet
azure storage blob upload manifests/single-vm-cf.yml ${container_name} ${template_version}/manifests/single-vm-cf.yml --quiet
azure storage blob upload manifests/multiple-vm-cf.yml ${container_name} ${template_version}/manifests/multiple-vm-cf.yml --quiet
