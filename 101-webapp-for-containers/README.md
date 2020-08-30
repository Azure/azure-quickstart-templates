# WebApp for Containers
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/PublicDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-webapp-for-containers/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-for-containers%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-for-containers%2Fazuredeploy.json)

This template deploys a WebApp for Containers app service that authenticates to an Azure Container Registry (ACR) using a service principal.

Before you use it, you should create a service principal and an ACR using the [pre-requisite template](prereqs/prereq.azuredeploy.json).

You can use [this Bash script](scripts/deploy.sh) to deploy all required resources. The script uses the Azure CLI to do the following: 

1. Create a service principal
2. Create a resource group
3. Create an Azure Container Registry (ACR) using the [pre-requisite template](prereqs/prereq.azuredeploy.json)
4. Build a container image using the sample [Dockerfile](scripts/Dockerfile) and push it to the ACR
5. Create a WebApp for Containers using the [template](azuredeploy.json)

Once the script is finished, it prints out the names of the created service principal and resource group together with the URL where you can access the running container.

`Tags: Linux, Azure Web App, Azure Container Registry, Docker, Microservices, Azure Active Directory`