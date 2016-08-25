#!/bin/bash

CURRENT_USER=$(whoami)
SETUP_SCRIPTS_LOCATION="/tmp/"
SETUP_SCRIPT="config_storage.sh"
SOURCE_URI="https://raw.githubusercontent.com/arroyc/azure-quickstart-templates/master/azure-jenkins/setup-scripts/"

sudo apt-get -y update
sudo apt-get -y install jq
sudo npm install -y -g azure-cli

#downloading initSetup script
sudo wget -O $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT $SOURCE_URI$SETUP_SCRIPT

sudo chmod +x $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT


