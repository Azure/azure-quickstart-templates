#!/bin/bash

SETUP_SCRIPTS_LOCATION="/opt/azure_jenkins_config/"
CONFIG_AZURE_SCRIPT="config_azure.sh"
CLEAN_STORAGE_SCRIPT="clear_storage_config.sh"
CREATE_STORAGE_SCRIPT="config_azure_jenkins_storage.sh"
CREATE_SERVICE_PRINCIPAL_SCRIPT="create_service_principal.sh"
INITIAL_JENKINS_CONFIG="init_jenkins.sh"
APTLY_SCRIPT="setup_aptly.sh"
JENKINS_GROOVY="init.groovy"
JENKINS_HOME="/var/lib/jenkins/"

JENKINS_USER="$1"
JENKINS_PWD="$2"
ORACLE_USER="$3"
ORACLE_PASSWORD="$4"
APTLY_REPO_NAME="$5"
SOURCE_URI="$6"

#delete any previous user if there is any
if [ ! -d $JENKINS_USER ]
then
    sudo rm -rvf $JENKINS_USER
fi
#restart jenkins
sudo service jenkins restart

if [ ! -d "$SETUP_SCRIPTS_LOCATION" ]; then
  sudo mkdir $SETUP_SCRIPTS_LOCATION
fi

# Download config_azure script
sudo wget -O $SETUP_SCRIPTS_LOCATION$CONFIG_AZURE_SCRIPT $SOURCE_URI$CONFIG_AZURE_SCRIPT
sudo chmod +x $SETUP_SCRIPTS_LOCATION$CONFIG_AZURE_SCRIPT

# Download clear_storage_config script
sudo wget -O $SETUP_SCRIPTS_LOCATION$CLEAN_STORAGE_SCRIPT $SOURCE_URI$CLEAN_STORAGE_SCRIPT
sudo chmod +x $SETUP_SCRIPTS_LOCATION$CLEAN_STORAGE_SCRIPT

# Download config_azure_jenkins_storage script
sudo wget -O $SETUP_SCRIPTS_LOCATION$CREATE_STORAGE_SCRIPT $SOURCE_URI$CREATE_STORAGE_SCRIPT
sudo chmod +x $SETUP_SCRIPTS_LOCATION$CREATE_STORAGE_SCRIPT

# Download create_service_principal script
sudo wget -O $SETUP_SCRIPTS_LOCATION$CREATE_SERVICE_PRINCIPAL_SCRIPT $SOURCE_URI$CREATE_SERVICE_PRINCIPAL_SCRIPT
sudo chmod +x $SETUP_SCRIPTS_LOCATION$CREATE_SERVICE_PRINCIPAL_SCRIPT

# Download init_jenkins config script
sudo wget -O $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG $SOURCE_URI$INITIAL_JENKINS_CONFIG
sudo chmod +x $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG

# Download Jenkins Groovy script
sudo wget -O $SETUP_SCRIPTS_LOCATION$JENKINS_GROOVY $SOURCE_URI$JENKINS_GROOVY

# Download aptly setup script
sudo wget -O $SETUP_SCRIPTS_LOCATION$APTLY_SCRIPT $SOURCE_URI$APTLY_SCRIPT
sudo chmod +x $SETUP_SCRIPTS_LOCATION$APTLY_SCRIPT

# Delete any existing config script
old_config_storage_file="/opt/azure_jenkins_config/config_storage.sh"
if [ -f $old_config_storage_file ]
then
  sudo rm -f $old_config_storage_file
fi

# Installing git 
sudo apt-get install git -y

#Replace the Oracle username and password in the init script
SED_STRING3='s/ORACLE_USER=\"\"/ORACLE_USER=\"'$ORACLE_USER'\"/'
sudo sed -i $SED_STRING3 $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG

SED_STRING4='s/ORACLE_PASSWORD=\"\"/ORACLE_PASSWORD=\"'$ORACLE_PASSWORD'\"/'
sudo sed -i $SED_STRING4 $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG

SED_STRING1='s/JENKINS_USER=\"\"/JENKINS_USER=\"'$JENKINS_USER'\"/'
sudo sed -i $SED_STRING1 $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG

SED_STRING2='s/JENKINS_PWD=\"\"/JENKINS_PWD=\"'$JENKINS_PWD'\"/'
sudo sed -i $SED_STRING2 $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG

SED_STRING5='s/APTLY_REPO_NAME=\"\"/APTLY_REPO_NAME=\"'$APTLY_REPO_NAME'\"/'
sudo sed -i $SED_STRING5 $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG
