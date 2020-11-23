# WebApp for Containers
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-for-containers%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-for-containers%2Fazuredeploy.json)

This template deploys a WebApp for Containers app service that authenticates to an Azure Container Registry (ACR) using a service principal.

Before you use it, you should create a service principal and an ACR. 

Follow the steps below to deploy all required resources using the Azure CLI in a Bash shell.

1. Create a service principal:

        uniqueId=$(env LC_CTYPE=C tr -dc 'a-z0-9' < /dev/urandom | fold -w 12 | head -n 1)
        servicePrincipalName="http://sp-$uniqueId"
        password=$(az ad sp create-for-rbac --name $servicePrincipalName --skip-assignment --query password --output tsv)
        appId=$(az ad sp show --id $servicePrincipalName --query appId --output tsv)
        servicePrincipalObjectId=$(az ad sp show --id $appId --query objectId --output tsv)

2. Create a resource group:

        resourceGroupName="rg-$uniqueId"
        az group create --name $resourceGroupName --location westeurope

3. Create an ACR and push a sample Docker image to it using the [pre-requisite template](prereqs/prereq.azuredeploy.json):

        containerRegistryName="$uniqueId"
        deploymentName="$uniqueId"
        az deployment group create --resource-group $resourceGroupName \
          --name $deploymentName \
          --template-file prereqs/prereq.azuredeploy.json \
          --parameters name=$containerRegistryName \
            sku="Basic" \
            servicePrincipalObjectId=$servicePrincipalObjectId

5. Create the Web App for Containers App Service using the [template](azuredeploy.json):

        webAppName="app-$uniqueId"
        dockerImageName=$(az deployment group show \
          --name $deploymentName \
          --resource-group $resourceGroupName \
          --query properties.outputs.containerImageName.value \
          --output tsv)

        az deployment group create \
            --resource-group $resourceGroupName \
            --template-file azuredeploy.json \
            --parameters \
              appServicePlanName="plan-$uniqueId" \
              webAppName=$webAppName \
              existingContainerRegistryName=$containerRegistryName \
              dockerImageName=$dockerImageName \
              dockerTag=latest \
              containerRegistryUsername=$appId \
              containerRegistryPassword=$password \
              appSettings="[ {\"name\": \"settingA\", \"value\": \"foo\" }, {\"name\": \"settingB\", \"value\": \"bar\" } ]"

6. Print the public URL of the app service to the console and browse to it to see the container in action: 

        echo "http://$webAppName.azurewebsites.net"

7. Clean up resources:

        az group delete --name $resourceGroupName -y
        az ad sp delete --id $servicePrincipalName

`Tags: Linux, Azure Web App, Azure Container Registry, Docker, Microservices, Azure Active Directory`