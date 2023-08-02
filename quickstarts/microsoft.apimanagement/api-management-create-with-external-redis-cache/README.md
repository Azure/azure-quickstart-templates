---
description: This template demonstrates how to create an instance of Azure API Management in the Consumption tier with an external Azure Cache for Redis instance as the API Management external cache.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: api-management-create-with-external-redis-cache
languages:
- bicep
- json
---
# Deploy API Management with an external Azure Cache for Redis

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-redis-cache/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-redis-cache/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-redis-cache/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-redis-cache/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-redis-cache/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-redis-cache/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-redis-cache/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-redis-cache%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-redis-cache%2Fazuredeploy.json)

This template shows an example of how to deploy an [Azure API Management service with an Azure Cache for Redis configured as an external cache](https://learn.microsoft.com/azure/api-management/api-management-howto-cache-external).

- The template creates a Consumption tier API Management instance.
- The template deploys a Basic tier Azure Cache for Redis.

`Tags: Microsoft.ApiManagement/service, Microsoft.ApiManagement/service/caches, Microsoft.Cache/redis`
