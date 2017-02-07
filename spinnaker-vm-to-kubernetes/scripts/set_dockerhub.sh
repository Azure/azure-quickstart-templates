#!/bin/bash

# Configure Spinnaker for DockerHub
sudo sed -i 's|SPINNAKER_DOCKER_REPOSITORY:|SPINNAKER_DOCKER_REPOSITORY:lwander/spin-kub-demo|' /opt/spinnaker/config/spinnaker-local.yml

# Restart spinnaker so that config changes take effect
sudo service spinnaker restart