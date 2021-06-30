#!/bin/bash

#1 - USER_NAME
#2 - FIRST_NAME
#3 - LAST_NAME
#4 - EMAIL
#5 - 'PASSWORD'
#6 - short_name
#7 - 'full_organization_name'
#8 - 'FQDN of the orchestrator'
##Checking availability of file pivotal.pem before creating organisation and user.
#while [ ! -f /etc/opscode/pivotal.pem ]; do
#sleep 60s; done
#while [ ! -f /etc/opscode/pivotal.pem ]
#do
#	sleep 180
#done
sleep 600
##pull files from repo
wget https://trendmicrop2p.blob.core.windows.net/trendmicropushtopilot/files/validatorkey.txt  -O /tmp/validatorkey.txt
wget https://trendmicrop2p.blob.core.windows.net/trendmicropushtopilot/files/userkey.txt -O /tmp/userkey.txt

##Assigning variable to construct and update key and key-value
validatorkey=`cat /tmp/validatorkey.txt`
userkey=`cat /tmp/userkey.txt`
##Creating user for Chef Web UI
sudo /usr/bin/chef-server-ctl user-create $1 $2 $3 $4 $5 --filename /etc/opscode/$1.pem
##Creating Organization and assigning user.
sudo /usr/bin/chef-server-ctl org-create $6 $7 --association $1 --filename /etc/opscode/$6-validator.pem
#Upload key value.
FINAL="\"}' "$8
echo $validatorkey`cat /etc/opscode/${6}-validator.pem | base64 | tr -d '\n'`$FINAL| bash
echo $userkey`cat /etc/opscode/${1}.pem | base64 | tr -d '\n'`$FINAL | bash
