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

# Create an Azure Container Registry (ACR)
containerRegistryName="$uniqueId"
az deployment group create --resource-group $resourceGroupName \
  --template-file ../prereqs/prereq.azuredeploy.json \
  --parameters name=$containerRegistryName \
    sku="Basic" \
    servicePrincipalObjectId=$servicePrincipalObjectId
  
# Build and Push a Docker Image to the ACR
dockerImageName='mgnsm/demo'
dockerTag='1.0.0'
az acr build . \
  --registry $containerRegistryName  \
  --file Dockerfile \
  --image "$dockerImageName:$dockerTag" \
  --image "$dockerImageName:latest"

# Create the Web App for Container App Service
webAppName="app-$uniqueId"
az deployment group create \
    --resource-group $resourceGroupName \
    --template-file ../azuredeploy.json \
    --parameters \
     appServicePlanName="plan-$uniqueId" \
     webAppName=$webAppName \
     existingContainerRegistryName=$containerRegistryName \
     dockerImageName=$dockerImageName \
     dockerTag=$dockerTag \
     containerRegistryUsername=$appId \
     containerRegistryPassword=$password \
     appSettings="[ {\"name\": \"settingA\", \"value\": \"foo\" }, {\"name\": \"settingB\", \"value\": \"bar\" } ]"
	 
echo "Service Principal: $servicePrincipalName"
echo "Resource Group: $resourceGroupName"
echo "Web App URL: http://$webAppName.azurewebsites.net"