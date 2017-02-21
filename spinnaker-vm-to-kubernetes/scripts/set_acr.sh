#!/bin/bash

registry_url=$1
client_id=$2
client_secret=$3
artifacts_location=$4
artifacts_location_sas_token=$5

clouddriver_config_file="/opt/spinnaker/config/clouddriver-local.yml"

# Configure Spinnaker for Docker Hub and Azure Container Registry
sudo wget -O $clouddriver_config_file "${artifacts_location}resources/docker_and_acr.yml${artifacts_location_sas_token}"

sudo sed -i "s|ACR_REGISTRY|${registry_url}|" $clouddriver_config_file
sudo sed -i "s|ACR_USERNAME|${client_id}|" $clouddriver_config_file
sudo sed -i "s|ACR_PASSWORD|${client_secret}|" $clouddriver_config_file

# Restart spinnaker so that config changes take effect
sudo restart spinnaker