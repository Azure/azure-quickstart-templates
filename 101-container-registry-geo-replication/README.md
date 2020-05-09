# Azure Container Registry with Geo-replication

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-container-registry-geo-replication/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-container-registry-geo-replication/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-container-registry-geo-replication/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-container-registry-geo-replication/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-container-registry-geo-replication/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-container-registry-geo-replication/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-container-registry-geo-replication%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-container-registry-geo-replication%2Fazuredeploy.json)



This template deploys an Azure Container Registry with [geo-replication enabled](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-geo-replication). Azure Container Registry is a PaaS offer for creating your own Docker image registry.

`Tags: Azure Container Registry, Docker`

## Solution overview and deployed resources

The following resources are deployed as part of the solution. Note the Azure Container Registry is set to **Premium** sku which is required to support Geo-Replication.

+ **Azure Container Registry**: Docker image registry
+ **Geo-Replicated registry**:  Docker image registry replication

## Login to your registry

Follow [this documentation](https://docs.microsoft.com/azure/container-registry/container-registry-authentication) to authenticate your docker client to your container registry.

#### Push images to your registry

For pushing docker images on your registry, follow [this documentation](https://docs.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)


