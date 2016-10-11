#!/usr/bin/env bash

# The template version should be same as variables('templateVersion') in azuredeploy.json
template_version="$1"
container_name="bosh-setup"

azure storage blob upload scripts/create_cert.sh ${container_name} ${template_version}/scripts/create_cert.sh
azure storage blob upload scripts/deploy_bosh.sh ${container_name} ${template_version}/scripts/deploy_bosh.sh
azure storage blob upload scripts/deploy_cloudfoundry.sh ${container_name} ${template_version}/scripts/deploy_cloudfoundry.sh
azure storage blob upload scripts/init.sh ${container_name} ${template_version}/scripts/init.sh
azure storage blob upload scripts/setup_env ${container_name} ${template_version}/scripts/setup_env
azure storage blob upload scripts/setup_env.py ${container_name} ${template_version}/scripts/setup_env.py
azure storage blob upload manifests/bosh.yml ${container_name} ${template_version}/manifests/bosh.yml
azure storage blob upload manifests/single-vm-cf.yml ${container_name} ${template_version}/manifests/single-vm-cf.yml
azure storage blob upload manifests/multiple-vm-cf.yml ${container_name} ${template_version}/manifests/multiple-vm-cf.yml
