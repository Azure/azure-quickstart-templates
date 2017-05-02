#!/bin/bash
keyName=$1
orchestratorbaseurl=$2
cckeyName=$3
componentBaseUrl=$4
nodename=$5
hostname=$6
vmUserName=$7
complianceadminusername=$8
env=$9
component=$10

URL="http://$orchestratorbaseurl:33001/key/$keyName"
echo $URL


#this API retrieves the validator.pem given a keyname, decodes it and stores it in validator.pem file
sudo curl -H "Content-Type: application/json" -X GET $URL | tr -d "\"" | base64 --decode > /etc/chef/validation.pem

URL2="http://$orchestratorbaseurl:33001/keys/$component/$complianceadminusername/envs/$env/nodes"
echo $URL2

sudo curl -H "Content-Type: application/json" -X POST -d '{"keyName":"'"$cckeyName"'", "componentBaseUrl":"'"$componentBaseUrl"'", "nodename":"'"$nodename"'", "hostname":"'"$hostname"'","vmUserName":"'"$vmUserName"'" }' $URL2 | tr -d "\""  > /home/$7/.ssh/id_rsa.pub

sudo cp /home/$7/.ssh/id_rsa.pub /home/$7/.ssh/authorized_keys

#Next step is run sudo chef-client so that it boot straps to server
sudo chef-client

