---
description: This template creates a consumption instance of Azure API Management with an external Azure Cache for Redis
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-api-management-create-with-external-redis-cache
languages:
- json
- bicep
---
# Deploy API Management with an external Azure Cache for Redis

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-redis-cache%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-redis-cache%2Fazuredeploy.json)

This template shows an example of how to deploy an [Azure API Management service with an Azure Cache for Redis configured as an external cache](https://learn.microsoft.com/azure/api-management/api-management-howto-cache-external).

- The template creates a Consumption tier API Management instance.
- The template deploys a Basic tier Azure Cache for Redis.

`Tags: Microsoft.ApiManagement/service, Microsoft.ApiManagement/service/caches, Microsoft.Cache/redis`
