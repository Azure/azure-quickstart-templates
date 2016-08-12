#!/bin/bash

SPINNAKER_CONFIG_DIR="/opt/spinnaker/config/"
TARGET_FILE="set-azure-credentials.sh"
SOURCE="https://raw.githubusercontent.com/scotmoor/azure-quickstart-templates/master/azure-spinnaker/scripts/set-azure-credentials.sh"

sudo curl -o $SPINNAKER_CONFIG_DIR$TARGET_FILE $SOURCE