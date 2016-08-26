#!/bin/bash

CURRENT_USER=$(whoami)
SETUP_SCRIPTS_LOCATION="/opt/azure_jenkins_config"
SETUP_SCRIPT="config_storage.sh"
CLEAN_STORAGE_SCRIPT="clear_storage_config.sh"
SOURCE_URI="https://raw.githubusercontent.com/arroyc/azure-quickstart-templates/master/azure-jenkins/setup-scripts/"

# #java
# echo "installing java"
# sudo apt-get -y update
# sudo apt-get -y install openjdk-7-jre
# sudo apt-get -y install openjdk-7-jdk

# #npm
# echo "installing npm"

# sudo apt-get -y update
# sudo apt-get -y install nodejs-legacy

# sudo apt-get -y install npm

 #azure-cli
 echo "installing azure-cli"
 sudo npm install -y -g azure-cli

 #install jq
 sudo apt-get -y update
 sudo apt-get -y install jq

# # install jenkins
# echo  "Installing Jenkins CI Server"

# wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
# sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
# sudo apt-get -y update
# sudo apt-get -y install jenkins

if [[ ! -e "$SETUP_SCRIPTS_LOCATION" ]]; then
  sudo mkdir $SETUP_SCRIPTS_LOCATION
fi

#downloading clear_storage_config script
sudo wget -O $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT $SOURCE_URI$CLEAN_STORAGE_SCRIPT
#downloading storage_config script
sudo wget -O $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT $SOURCE_URI$SETUP_SCRIPT

sudo chmod +x $SETUP_SCRIPTS_LOCATION$SETUP_SCRIPT


