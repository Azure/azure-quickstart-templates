#!/bin/bash

STACKNAME="$1"
if [ $# != 1 ]; then
   echo "Usage:  $0 <stack name>"
fi
if [ ! -e ${STACKNAME}-parameters.json ]; then
   echo "${STACKNAME}-parameters.json file not found. Make one."
fi

# Create a group, launch a stack
CURTIME=`date +%Y%m%d%H%M`
/usr/bin/az group create  --name ${STACKNAME} --location westus
/usr/bin/az group deployment create --name ${STACKNAME}-${CURTIME} --resource-group ${STACKNAME} --template-file azuredeploy.json --parameters @${STACKNAME}-parameters.json
