---
description: This template creates a Redis Cache that can be used as Vector DB to store and query embeddings via indexes. For this feature, the Redis Search module is activated in Azure Redis
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: redis-enterprise-vectordb
languages:
- bicep
- json
---
# Redis Enterprise with Vector DB

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cache/redis-cache/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cache%2Fredis-cache%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cache%2Fredis-cache%2Fazuredeploy.json)

Create an Azure Cache for Redis instance with `Redis Search` module installed on it. Redis Search module allows you to use Redis Cache as a vector DB where user can store embeddings, create indexes and then query the embeddings using vector search, semantic search and hybrid search. Currently, only Azure Redis Enterprise supports the `Redis Search` module. This template will provision an Enterprise Azure Cache for Redis along with Redis search module installed on top of it.

For information about using this template, see [Create an Azure Cache for Redis using an ARM template](https://azure.microsoft.com/documentation/articles/cache-redis-cache-arm-provision/).

`Tags: Microsoft.Cache/redis`
