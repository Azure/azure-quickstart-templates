#!/bin/bash

registry_url=$1
client_id=$2
client_secret=$3

# Configure Spinnaker for Azure Container Registry
sudo sed -i "s|SPINNAKER_DOCKER_REGISTRY:https://index.docker.io/|SPINNAKER_DOCKER_REGISTRY:https://${registry_url}/|" /opt/spinnaker/config/spinnaker-local.yml
sudo sed -i "s|SPINNAKER_DOCKER_USERNAME:|SPINNAKER_DOCKER_USERNAME:${client_id}|" /opt/spinnaker/config/spinnaker-local.yml
sudo sed -i "s|SPINNAKER_DOCKER_PASSWORD_FILE:|SPINNAKER_DOCKER_PASSWORD_FILE:/opt/spinnaker/config/acrPswd|" /opt/spinnaker/config/spinnaker-local.yml

sudo touch /opt/spinnaker/config/acrPswd
echo $client_secret | sudo dd status=none of=/opt/spinnaker/config/acrPswd

# Restart spinnaker so that config changes take effect
sudo service spinnaker restart