#!/bin/bash

CURRENT_USER=$(whoami)
SETUP_SCRIPTS_LOCATION="/opt/azure_jenkins_config/"
SETUP_SCRIPT="config_azure.sh"
CLEAN_STORAGE_SCRIPT="clear_storage_config.sh"
SOURCE_URI="https://raw.githubusercontent.com/arroyc/azure-quickstart-templates/master/azure-jenkins/setup-scripts/"

#azure-cli
sudo npm install -y -g azure-cli

#install jq
sudo apt-get -y update
sudo apt-get -y install jq

#delete any existing config script
sudo rm -f /opt/config_storage.sh

if [ ! -d "$SETUP_SCRIPTS_LOCATION" ]; then
  sudo mkdir $SETUP_SCRIPTS_LOCATION

  #downloading clear_storage_config script
  sudo wget -O $SETUP_SCRIPTS_LOCATION$SETUP_AZURE_CREDENTIALS $SOURCE_URI$SETUP_AZURE_CREDENTIALS
  sudo chmod +x $SETUP_SCRIPTS_LOCATION$SETUP_AZURE_CREDENTIALS

  #downloading config_azure script
  sudo wget -O $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT $SOURCE_URI$SETUP_SCRIPT
  sudo chmod +x $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT

fi


