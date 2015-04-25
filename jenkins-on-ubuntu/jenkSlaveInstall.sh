#!/bin/bash

#########################################################
# Script Name: jenkSlaveInstall.sh
# Author: Dennis Angeline - Full Scale 180 Inc 
# Version: 0.1
# Last Modified By:       Dennis Angeline
# Description:
#  This script install Jenkins slave on an Ubuntu VM image
# Parameters :
# Note : 
# This script has only been tested on Ubuntu 14.04 LTS and must be root
####################################################### 

grep -q "${HOSTNAME}" /etc/hosts

if [ $? == 0 ];
then
  echo "%{HOSTNAME} found in /etc/hosts"
else
  echo "${HOSTNAME} not found in  /etc/hosts"
  #sudo echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts
  #log "hostname %{HOSTNAME} added to /etc/hosts"
fi

$MASTERNODE=$1
$SLAVENODE=$2

wget http://$MASTERNODE/jnlpJars/slave.jar -O ~/slave.jar
sudo java -jar slave.jar -jnlpUrl http://$MASTERNODE:8080/computer/$SLAVENODE/slave-agent.jnlp

