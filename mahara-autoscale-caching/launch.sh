#!/bin/bash

export MAHARA_RG_NAME=mahara-mysql-01
export MAHARA_RG_LOCATION=westus
export MAHARA_DEPLOYMENT_NAME=MainDeployment


az group create --name $MAHARA_RG_NAME --location $MAHARA_RG_LOCATION
az group deployment create --name $MAHARA_DEPLOYMENT_NAME --resource-group $MAHARA_RG_NAME --template-file azuredeploy.json --parameters test.json


