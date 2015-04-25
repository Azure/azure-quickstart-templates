#!/bin/bash

#########################################################
# Script Name: jenkSlaveInstall.sh
# Author: Dennis Angeline - Full Scale 180 Inc 
# Version: 0.1
# Last Modified By:       Dennis Angeline
# Description:
#  This script install Jenkins slave on an Ubuntu VM image
# Parameters :
#  MASTERNODE: The ip address of the master node
#  SLAVENODE: The name of this slave node
# Note : 
#  This script has only been tested on Ubuntu 14.04 LTS and must be root
####################################################### 

MASTERNODE=$1
SLAVENODE=$2

#### Install Java
echo "Installing openjdk-7"
apt-get -y update 
apt-get -y install openjdk-7-jdk

echo "Downloading slave.jar from $MASTERNODE"
wget http://$MASTERNODE:8080/jnlpJars/slave.jar -O ~/slave.jar

echo "Executing slave.jar with http://$MASTERNODE:8080/computer/$SLAVENODE/slave-agent.jnlp"
sudo java -jar ~/slave.jar -jnlpUrl http://$MASTERNODE:8080/computer/$SLAVENODE/slave-agent.jnlp

