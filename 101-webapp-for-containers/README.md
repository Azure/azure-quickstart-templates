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

You can use [this Bash script](scripts/deploy.sh) to deploy all required resources. The script uses the Azure CLI to do the following: 

1. Create a service principal
2. Create a resource group
3. Create an Azure Container Registry (ACR) using the [pre-requisite template](prereqs/prereq.azuredeploy.json)
4. Import the sample [nginxdemos/hello](https://hub.docker.com/r/nginxdemos/hello/) Docker image to the ACR from Docker Hub using the [pre-requisite template](prereqs/prereq.azuredeploy.json)
5. Create a WebApp for Containers using the [template](azuredeploy.json)

Once the script is finished, it prints out the names of the created service principal and resource group together with the URL where you can access the running container.

Below is an example of how to use the Azure CLI to deploy the template from a bash shell:

    az deployment group create \
        --resource-group <resource-group> \
        --template-file azuredeploy.json \
        --parameters \
            webAppName=<webapp> \
            existingContainerRegistryName=<acr> \
            dockerImageName=<yourorganization\yourimage> \
            dockerTag=1.0.0 \
            containerRegistryUsername=<servicePrincipal-appId> \
            containerRegistryPassword=<servicePrincipal-password> \
            appSettings="[ {\"name\": \"settingA\", \"value\": \"foo\" }, {\"name\": \"settingB\", \"value\": \"bar\" } ]"

- `<webapp>` should be replaced by a globally unique name of the web app
- `<acr>` should be replaced by the name of the ACR that contains the Docker image
- `<yourorganization\yourimage>` is the name of the Docker image in the ACR
- `<servicePrincipal-appId>` should be replaced by the `appId` of a service principal that has `AcrPull` permissions to the ACR
- `<servicePrincipal-password>` should be replaced by password for the service principal with `AcrPull` permissions

`Tags: Linux, Azure Web App, Azure Container Registry, Docker, Microservices, Azure Active Directory`