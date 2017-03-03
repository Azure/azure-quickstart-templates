#!/bin/bash

# This script is used by the azure custom script extension

SETUP_SCRIPTS_LOCATION="/opt/azure_jenkins_config/"
CLEAN_STORAGE_SCRIPT="clear_storage_config.sh"
CREATE_STORAGE_SCRIPT="config_azure_jenkins_storage.sh"
CREATE_SERVICE_PRINCIPAL_SCRIPT="create_service_principal.sh"
INITIAL_JENKINS_CONFIG="init_jenkins.sh"
APTLY_SCRIPT="setup_aptly.sh"
JENKINS_GROOVY="init.groovy"
JENKINS_HOME="/var/lib/jenkins/"

JENKINS_USER=""
JENKINS_PWD=""
ORACLE_USER=""
ORACLE_PASSWORD=""
APTLY_REPO_NAME=""
SOURCE_URI=""

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
   -ju)
   JENKINS_USER="$2"
   shift
   ;;
   -jp)
   JENKINS_PWD="$2"
   shift
   ;;
   -ou)
   ORACLE_USER="$2"
   shift
   ;;
   -op)
   ORACLE_PASSWORD="$2"
   shift
   ;;
   -a)
   APTLY_REPO_NAME="$2"
   shift
   ;;
   -su)
   SOURCE_URI="$2"
   shift
   ;;
   *)

   ;;
esac
shift
done

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

# Download clear_storage_config script
sudo wget -O $SETUP_SCRIPTS_LOCATION$CLEAN_STORAGE_SCRIPT $SOURCE_URI$CLEAN_STORAGE_SCRIPT
sudo chmod +x $SETUP_SCRIPTS_LOCATION$CLEAN_STORAGE_SCRIPT

# Download config_azure_jenkins_storage script
sudo wget -O $SETUP_SCRIPTS_LOCATION$CREATE_STORAGE_SCRIPT $SOURCE_URI$CREATE_STORAGE_SCRIPT
sudo chmod +x $SETUP_SCRIPTS_LOCATION$CREATE_STORAGE_SCRIPT

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
sudo sed -i 's/ORACLE_USER=\"\"/ORACLE_USER=\"'$ORACLE_USER'\"/' $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG
sudo sed -i 's/ORACLE_PASSWORD=\"\"/ORACLE_PASSWORD=\"'$ORACLE_PASSWORD'\"/' $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG
sudo sed -i 's/JENKINS_USER=\"\"/JENKINS_USER=\"'$JENKINS_USER'\"/' $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG
sudo sed -i 's/JENKINS_PWD=\"\"/JENKINS_PWD=\"'$JENKINS_PWD'\"/' $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG
sudo sed -i 's/APTLY_REPO_NAME=\"\"/APTLY_REPO_NAME=\"'$APTLY_REPO_NAME'\"/' $SETUP_SCRIPTS_LOCATION$INITIAL_JENKINS_CONFIG
