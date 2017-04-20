#!/bin/bash

# Get azure data 
# clientId : -c 
# AppKey: -a
# Default values
JENKINS_USERNAME=""
JENKINS_PASSWORD=""

while getopts ":t:s:p:c:h:r:l:k:u:q:f:a:i:" opt; do
  case $opt in
    t) TENANTID="$OPTARG"
    ;;
    p) PASSWORD="$OPTARG"
    ;;
    c) CLIENTID="$OPTARG"
    ;;
    s) SUBSCRIPTIONID="$OPTARG"
    ;;
    h) PACKERSTORAGEACCOUNT="$OPTARG"
    ;;
    r) RESOURCEGROUP="$OPTARG"
    ;;
    l) RESOURCEGROUPLOCATION="$OPTARG"
    ;;
    k) KEYVAULT="$OPTARG"
    ;;
    i) JENKINS_FQDN="$OPTARG"
    ;;
    u) JENKINS_USERNAME="$OPTARG"
    ;;
    q) JENKINS_PASSWORD="$OPTARG"
    ;;
    f) FRONT50_STORAGE="$OPTARG"
    ;;
    a) FRONT50_KEY="$OPTARG"
    ;;
  esac
done

WORKDIR=$(pwd)
# Usually the workdir is /var/lib/waagent/custom-script/download/0
JENKINS_URL='http:\/\/'$JENKINS_FQDN
DEBIAN_REPO='http:\/\/ppa.launchpad.net\/openjdk-r\/ppa\/ubuntu trusty main;'$JENKINS_URL
SED_FILE=$WORKDIR"/sedCommand.sed"

sudo printf "Upgrading the environment\n"
# Update and upgrade packages
sudo apt-mark hold walinuxagent grub-legacy-ec2
sudo printf "Holding walinuxagent\n" 
sudo apt-get update -y
sudo printf "apt-get update completed\n" 
sudo rm /var/lib/dpkg/updates/*
sudo printf "directory /var/lib/dpkg/updates removed\n"
sudo apt-get upgrade -y
sudo printf "apt-get upgrade completed\n" 

# Install Spinnaker on the VM with no cassandra
sudo printf "Starting to install Spinnaker\n" 
curl --silent https://raw.githubusercontent.com/spinnaker/spinnaker/master/InstallSpinnaker.sh | sudo bash -s -- --cloud_provider azure --azure_region $RESOURCEGROUPLOCATION --noinstall_cassandra

sudo printf "Spinnaker has been installed\n" 

# configure to not use cassandra
sudo /opt/spinnaker/install/change_cassandra.sh --echo=inMemory --front50=azs
sudo printf "Configured to not use cassandra" 

# Configuring the /opt/spinnaker/config/default-spinnaker-local.yml
# Let's create the sed command file and run the sed command

sudo printf "Setting up sedCommand \n" 

sudo printf "s/enabled: \${SPINNAKER_AZURE_ENABLED:false}/enabled: \${SPINNAKER_AZURE_ENABLED:true}/g\n" > $SED_FILE
sudo printf "s/defaultRegion: \${SPINNAKER_AZURE_DEFAULT_REGION:westus}/defaultRegion: \${SPINNAKER_AZURE_DEFAULT_REGION:$RESOURCEGROUPLOCATION}/g\n" >> $SED_FILE
sudo printf "s/clientId:$/& %s/\n" $CLIENTID >> $SED_FILE
sudo printf "s/appKey:$/& %s/\n" $PASSWORD >> $SED_FILE
sudo printf "s/tenantId:$/& %s/\n" $TENANTID >> $SED_FILE
sudo printf "s/subscriptionId:$/& %s/\n" $SUBSCRIPTIONID >> $SED_FILE
# Adding the PackerResourceGroup, the PackerStorageAccount, the defaultResourceGroup and the defaultKeyVault  
sudo printf "s/packerResourceGroup:$/& %s/\n" $RESOURCEGROUP >> $SED_FILE
sudo printf "s/packerStorageAccount:$/& %s/\n" $PACKERSTORAGEACCOUNT >> $SED_FILE
sudo printf "s/defaultResourceGroup:$/& %s/\n" $RESOURCEGROUP >> $SED_FILE
sudo printf "s/defaultKeyVault:$/& %s/\n" $KEYVAULT >> $SED_FILE

# Enable Igor for the integration with Jenkins
sudo printf "/igor:/ {\n           N\n           N\n           N\n           /enabled:/ {\n             s/enabled:.*/enabled: true/\n             P\n             D\n         }\n}\n" >> $SED_FILE

# Configure the Jenkins instance
sudo printf "/name: Jenkins.*/ {\n N\n /baseUrl:/ { s/baseUrl:.*/baseUrl: %s:8080/ }\n" $JENKINS_URL >> $SED_FILE
sudo printf " N\n /username:/ { s/username:/username: %s/ }\n" $JENKINS_USERNAME >> $SED_FILE
sudo printf " N\n /password:/ { s/password:/password: %s/ }\n" $JENKINS_PASSWORD >> $SED_FILE
sudo printf "}\n" >> $SED_FILE

# Configure Azure storage
sudo printf "/azs:/ {\n   N\n   s/enabled: false/enabled: true/\n   N\n   s/storageAccountName:/storageAccountName: $FRONT50_STORAGE/\n   N\n   s|storageAccountKey:|storageAccountKey: $FRONT50_KEY|\n   }\n" >> $SED_FILE

sudo printf "sedCommand.sed file created\n" 

# Set the variables in the spinnaker-local.yml file
sudo sed -i -f $SED_FILE /opt/spinnaker/config/spinnaker-local.yml 
sudo printf "spinnaker-local.yml file has been updated\n" 

# Configure rosco.yml file  
sudo sed -i "/# debianRepository:/s/.*/debianRepository: $DEBIAN_REPO:9999 trusty main/" /opt/rosco/config/rosco.yml
sudo sed -i '/defaultCloudProviderType/s/.*/defaultCloudProviderType: azure/' /opt/rosco/config/rosco.yml
sudo printf "rosco.yml file has been updated\n" 

# Adding apt-key key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB9B1D8886F44E2A
sudo printf "apt-key done\n" 

# Enable Azure provider in /etc/default/spinnaker
sudo sed -i '/SPINNAKER_AZURE_ENABLED=false/s/.*/SPINNAKER_AZURE_ENABLED=true/' /etc/default/spinnaker

# Removing debug file
sudo rm -f $SED_FILE

# rebooting the VM to avoid issues with front50
sudo service spinnaker restart

