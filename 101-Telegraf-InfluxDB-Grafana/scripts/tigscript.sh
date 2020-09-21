#!/bin/bash

# Script parameters from arguments
configfile=$1
HostIP=$(dig +short myip.opendns.com @resolver1.opendns.com)


apt-get update
apt-get install software-properties-common -y
apt-add-repository ppa:ansible/ansible -y
apt-get update
apt-get install ansible -y
apt-get install unzip -y

cd /home/

if [ -e Configfiles.* ];
then
  if [ -d /home/Configfiles ];
  then
        rm -rf Configfiles.*
	rm -rf /home/Configfiles
	echo "directory delete"
  fi
fi
wget $configfile
unzip Configfiles.zip -d /home/Configfiles/


HOME=/root ansible-playbook /home/Configfiles/ansible/docker_install.yml  --extra-vars "HostIP=$HostIP" -vvv


