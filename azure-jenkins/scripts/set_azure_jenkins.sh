#!/bin/bash

CURRENT_USER=$(whoami)
SETUP_SCRIPTS_LOCATION="/opt/azure_jenkins_config/"
CONFIG_AZURE_SCRIPT="config_azure.sh"
CLEAN_STORAGE_SCRIPT="clear_storage_config.sh"
SOURCE_URI="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/azure-jenkins/setup-scripts/"
JENKINS_USER="/var/lib/jenkins/users/"
JENKINS_HOME="/var/lib/jenkins/"
JENKINS_CONFIG="config.xml"
ADMINUSER=$1
ADMINPWD=$2
#download jenkins-cli and secured jenkins config to create new user
wget -O /opt/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
chmod +x /opt/jenkins-cli.jar
#delete any previous user if there is any
if [ ! -d $JENKINS_USER ] 
then
    sudo rm -rvf $JENKINS_USER
fi
#create adminuser and password
echo "hpsr=new hudson.security.HudsonPrivateSecurityRealm(false); hpsr.createAccount('$ADMINUSER', '$ADMINPWD')" | sudo java -jar /opt/jenkins-cli.jar -s http://localhost:8080 groovy =

#enable secure jenkins secure config
sudo mv /var/lib/jenkins/config.xml /var/lib/jenkins/config.xml.bak
sudo mkdir /var/lib/jenkins/test1
sudo wget -O /var/lib/jenkins/config.xml https://arroycsafestorage.blob.core.windows.net/testsafe/config.xml
sudo mkdir /var/lib/jenkins/arjun1/test2
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

#delete any existing config script
old_config_storage_file="/opt/config_storage.sh"
if [ -f $old_config_storage_file ]
then
  sudo rm -f $old_config_storage_file
fi

exit 0