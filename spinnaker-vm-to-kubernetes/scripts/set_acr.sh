#!/bin/bash

registry_url=$1
client_id=$2
client_secret=$3
artifacts_location=$4
artifacts_location_sas_token=$5

# Configure Spinnaker for Docker Hub and Azure Container Registry
sudo wget -O /opt/spinnaker/config/clouddriver-local.yml "${artifacts_location}resources/docker_and_acr.yml${artifacts_location_sas_token}"

sudo sed -i "s|ACR_REGISTRY|${registry_url}|" /opt/spinnaker/config/clouddriver-local.yml
sudo sed -i "s|ACR_USERNAME|${client_id}|" /opt/spinnaker/config/clouddriver-local.yml
sudo sed -i "s|ACR_PASSWORD|${client_secret}|" /opt/spinnaker/config/clouddriver-local.yml

# Restart spinnaker so that config changes take effect
sudo restart spinnaker