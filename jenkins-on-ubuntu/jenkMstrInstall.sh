#!/bin/bash

#########################################################
# Script Name: jenkMstrInstall.sh
# Author: Dennis Angeline - Full Scale 180 Inc 
# Version: 0.1
# Last Modified By:       Dennis Angeline
# Description:
#    This script install Jenkins master on an Ubuntu VM image
#    and configures the master to have $NODECNT dumb slave nodes
# Parameters : 
#    NODECNT - An int value of slave nodes to add to the master config
# Note : 
#    This script has only been tested on Ubuntu 14.04 LTS
######################################################### 

if [ "$1" == "" ]; then
    NODECNT=1
else
    NODECNT=$1
fi

grep -q "${HOSTNAME}" /etc/hosts

if [ $? == 0 ];
then
  echo "${HOSTNAME} found in /etc/hosts"
else
  echo "${HOSTNAME} not found in  /etc/hosts"
  sudo echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts
  echo "hostname ${HOSTNAME} added to /etc/hosts"
fi

#### Install Java
echo "Installing openjdk-7"
apt-get -y update 
apt-get -y install openjdk-7-jdk

#### Install Jemkins
echo "Installing Jenkins master"
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get -y install jenkins

### wait for Jenkins to start
### TODO add logic to wait for 200 response
echo "Waiting for Jenkins master to start..."
sleep 60

#### Run groovy script to add nodes
echo "Configuring Jenkins master with $NODECNT dumb slave node(s)"
sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 groovy jenkAddNode $NODECNT
