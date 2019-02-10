#!/bin/bash
TENANTNAME=$1
RESOURCEGROUPNAME=$2
LOCATION=$3

Usage(){
    echo "This script is used to create a new Azure Active Directory application registration.\n"
}

print_status () {
echo -e "\e[32m $1 \e[0m"
}

az login

#Create AAD application registration for web API application
tenantName="${TENANTNAME,,}"
apiAppIdUrl=https://$tenantName/webapp-keyvault-storage-msi
apiDisplayName='webapp-keyvault-storage-msi'
print_status "Creating API app registration"
az ad app create --display-name $apiDisplayName --homepage https://localhost:44337/signin-oidc --identifier-uris $apiAppIdUrl
apiAppId=$(az ad app show --id $apiAppIdUrl --query "appId" --output tsv)

print_status "Creating resource group"
az group create --name $RESOURCEGROUPNAME --location $LOCATION

print_status "Deploying ARM template"
az group deployment create \
  --name "webapp-keyvault-storage-msi-deployment" \
  --resource-group $RESOURCEGROUPNAME \
  --template-file "../azuredeploy.json" \
  --parameters "@../azuredeploy.parameters.json"

#Add the web apps' URLs as a reply URL to the AAD application.
webapp=$(az group deployment show -g $RESOURCEGROUPNAME -n 'webapp-keyvault-storage-msi-deployment' --query properties.outputs.appUrl.value --output tsv)
print_status "Updating web app registration with replyUrl from newly created web app"
az ad app update --id $appId --password $clientSecret --reply-urls $webapp/signin-oidc https://localhost:44337/signin-oidc

