#!/bin/bash

# Generate a unique 12 character alphanumeric string to ensure unique resource names
uniqueId=$(env LC_CTYPE=C tr -dc 'a-z0-9' < /dev/urandom | fold -w 12 | head -n 1)

# Create a Service Principal
servicePrincipalName="http://sp-$uniqueId"
password=$(az ad sp create-for-rbac --name $servicePrincipalName --skip-assignment --query password --output tsv)
appId=$(az ad sp show --id $servicePrincipalName --query appId --output tsv)
servicePrincipalObjectId=$(az ad sp show --id $appId --query objectId --output tsv)

# Create a resource group to hold the resources
resourceGroupName="rg-$uniqueId"
az group create --name $resourceGroupName --location westeurope

# Create an Azure Container Registry (ACR) and push a sample Docker image to it
containerRegistryName="$uniqueId"
deploymentName="$uniqueId"
az deployment group create --resource-group $resourceGroupName \
  --name $deploymentName \
  --template-file ../prereqs/prereq.azuredeploy.json \
  --parameters name=$containerRegistryName \
    sku="Basic" \
    servicePrincipalObjectId=$servicePrincipalObjectId
	
# Create the Web App for Containers App Service
webAppName="app-$uniqueId"
dockerImageName=$(az deployment group show \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --query properties.outputs.containerImageName.value \
  --output tsv)

az deployment group create \
    --resource-group $resourceGroupName \
    --template-file ../azuredeploy.json \
    --parameters \
     appServicePlanName="plan-$uniqueId" \
     webAppName=$webAppName \
     existingContainerRegistryName=$containerRegistryName \
     dockerImageName=$dockerImageName \
     dockerTag=latest \
     containerRegistryUsername=$appId \
     containerRegistryPassword=$password \
     appSettings="[ {\"name\": \"settingA\", \"value\": \"foo\" }, {\"name\": \"settingB\", \"value\": \"bar\" } ]"
	 
echo "Service Principal: $servicePrincipalName"
echo "Resource Group: $resourceGroupName"
echo "Web App URL: http://$webAppName.azurewebsites.net"