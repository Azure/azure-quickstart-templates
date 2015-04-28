#!/bin/bash

#########################################################
# Script Name: dsenode.sh
# Author: Trent Swanson - Full Scale 180 Inc github:(trentmswanson)
# Version: 0.1
# Last Modified By:       Trent Swanson
# Description:
#  This script prepares an Ubuntu VM image for Datastax OpsCenter Node Cluster Installation and Configure
# Parameters :
# Note : 
# This script has only been tested on Ubuntu 14.04 LTS and must be root
######################################################### 

bash vm-disk-utils-0.1.sh

# TEMP FIX - Re-evaluate and remove when possible
# This is an interim fix for hostname resolution in current VM (If it does not exist add it)
grep -q "${HOSTNAME}" /etc/hosts
if [ $? == 0 ];
then
  echo "${HOSTNAME}found in /etc/hosts"
else
  echo "${HOSTNAME} not found in /etc/hosts"
  # Append it to the hsots file if not there
  echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts
  log "hostname ${HOSTNAME} added to /etchosts"
fi

#Install Java
add-apt-repository -y ppa:webupd8team/java
apt-get -y update 
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get -y install oracle-java7-installer

#Need to see if we can find a better solution
chmod 777 /mnt
chmod 777 /datadisks
