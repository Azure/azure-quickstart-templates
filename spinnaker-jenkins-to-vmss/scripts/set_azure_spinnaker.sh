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
DEBUG_FILE=$WORKDIR"/debugfile"
SED_FILE=$WORKDIR"/sedCommand.sed"

# Record the Variables in text file for debugging purposes  
sudo printf "TENANTID=%s\n" $TENANTID > $DEBUG_FILE
sudo printf "SPNCLIENTSECRET=%s\n" $PASSWORD >> $DEBUG_FILE
sudo printf "SPNCLIENTID=%s\n" $CLIENTID >> $DEBUG_FILE
sudo printf "SUBSCRIPTIONID=%s\n" $SUBSCRIPTIONID >> $DEBUG_FILE
sudo printf "PACKERSTORAGEACCOUNT=%s\n" $PACKERSTORAGEACCOUNT >> $DEBUG_FILE
sudo printf "RESOURCEGROUP=%s\n" $RESOURCEGROUP >> $DEBUG_FILE
sudo printf "RESOURCEGROUPLOCATION=%s\n" $RESOURCEGROUPLOCATION >> $DEBUG_FILE
sudo printf "KEYVAULT=%s\n" $KEYVAULT >> $DEBUG_FILE
sudo printf "JENKINS_URL=%s\n" $JENKINS_URL >> $DEBUG_FILE
sudo printf "FRONT50_KEY=%s\n" $FRONT50_KEY >> $DEBUG_FILE

sudo printf "working directory is %s\n" $WORKDIR >> $DEBUG_FILE

sudo printf "Upgrading the environment\n" >> $DEBUG_FILE
# Update and upgrade packages
sudo apt-mark hold walinuxagent grub-legacy-ec2
sudo printf "Holding walinuxagent\n" >> $DEBUG_FILE
sudo apt-get update -y
sudo printf "apt-get update completed\n" >> $DEBUG_FILE
sudo rm /var/lib/dpkg/updates/*
sudo printf "directory /var/lib/dpkg/updates removed\n" >> $DEBUG_FILE
sudo apt-get upgrade -y
sudo printf "apt-get upgrade completed\n" >> $DEBUG_FILE

# Install Spinnaker on the VM with no cassandra
sudo printf "Starting to install Spinnaker\n" >> $DEBUG_FILE
curl --silent https://raw.githubusercontent.com/spinnaker/spinnaker/master/InstallSpinnaker.sh | sudo bash -s -- --cloud_provider azure --azure_region $RESOURCEGROUPLOCATION --noinstall_cassandra

sudo printf "Spinnaker has been installed\n" >> $DEBUG_FILE

# configure to not use cassandra
sudo /opt/spinnaker/install/change_cassandra.sh --echo=inMemory --front50=azs
sudo printf "Configured to not use cassandra" >> $DEBUG_FILE

# Configuring the /opt/spinnaker/config/default-spinnaker-local.yml
# Let's create the sed command file and run the sed command

sudo printf "Setting up sedCommand \n" >> $DEBUG_FILE

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

# Disable cassandra
sudo printf "/front50:/ {\n    N\n     /cassandra:/ {\n         N\n         s/enabled: true/enabled: false/\n         }\n    }\n" >> $SED_FILE

# Configure Azure storage
sudo printf "/azs:/ {\n   N\n   s/enabled: false/enabled: true/\n   N\n   s/storageAccountName:/storageAccountName: $FRONT50_STORAGE/\n   N\n   s|storageAccountKey:|storageAccountKey: $FRONT50_KEY|\n   }\n" >> $SED_FILE

sudo printf "sedCommand.sed file created\n" >> $DEBUG_FILE

# Set the variables in the spinnaker-local.yml file
sudo sed -i -f $SED_FILE /opt/spinnaker/config/spinnaker-local.yml 
sudo printf "spinnaker-local.yml file has been updated\n" >> $DEBUG_FILE

# Configure rosco.yml file  
sudo sed -i "/# debianRepository:/s/.*/debianRepository: $DEBIAN_REPO:9999 trusty main/" /opt/rosco/config/rosco.yml
sudo sed -i '/defaultCloudProviderType/s/.*/defaultCloudProviderType: azure/' /opt/rosco/config/rosco.yml
sudo printf "rosco.yml file has been updated\n" >> $DEBUG_FILE

# Adding apt-key key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB9B1D8886F44E2A
sudo printf "apt-key done\n" >> $DEBUG_FILE

# Removing debug file
# sudo rm -f $DEBUG_FILE
# sudo rm -f $SED_FILE

# rebooting the VM to avoid issues with front50
sudo shutdown -r now "Rebooting the system after Spinnaker installation" 

