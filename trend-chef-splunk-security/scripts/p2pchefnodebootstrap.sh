#!/bin/bash
keyName=$1
orchestratorbaseurl=$2

URL="http://$orchestratorbaseurl:33001/key/$keyName"
echo $URL


#this API retrieves the validator.pem given a keyname, decodes it and stores it in validator.pem file
sudo curl -H "Content-Type: application/json" -X GET $URL | tr -d "\"" | base64 --decode > /etc/chef/validation.pem


#Next step is run sudo chef-client so that it boot straps to server
sudo chef-client