#!/bin/bash

if [  $# -eq 0 ]; then
    echo "You need to pass the resource group name as the first positional parameter"
    exit 1
fi

cd ../prereqs/

echo "Creating the prerequisites to the solution"
az group deployment create --resource-group $1 --template-file prereq.azuredeploy.json

SUBNET_ID=$(az group deployment show -g $1 -n prereq.azuredeploy --query properties.outputs.subnetId.value)
SUBNET_ID_FILTERED=$(echo $SUBNET_ID | cut -d '"' -f 2)

cd ../nested/

echo "Deploying the whole solution"
az group deployment create --resource-group $1 --template-file nfs-ha.json --parameters nfs-ha.param.json --parameters "subnetId=$SUBNET_ID_FILTERED"

echo "Deployment of NFS HA server done"
