#!/bin/bash

artifacts_location=$1
artifacts_location_sas_token=$2

clouddriver_config_file="/opt/spinnaker/config/clouddriver-local.yml"

# Configure Spinnaker for DockerHub
sudo wget -O $clouddriver_config_file "${artifacts_location}resources/docker_only.yml${artifacts_location_sas_token}"

# Restart spinnaker so that config changes take effect
sudo restart spinnaker