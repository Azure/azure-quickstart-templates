---
description: This template creates a free-tier Azure Cosmos DB account for SQL API with a database with shared throughput and container.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: cosmosdb-free
languages:
- bicep
- json
---
# Create a free-tier Azure Cosmos DB account

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-free/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-free/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-free/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-free/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-free/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-free/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-free/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-free%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-free%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-free%2Fazuredeploy.json)

This template will create a free-tier Azure Cosmos account for SQL API in a single region, a database with shared throughput of 1000 RU/s and one container. Accounts in free tier will not be billed for usage of 1000 RU/s or 50 GB of data or less.

> [!IMPORTANT]
> Only one free-tier account can be created per subscription.

Below are the parameters which can be user configured in the parameters file or template including:

- **Location:** Enter location for primary region.
- **Account Name:** Enter the database name for the account.

`Tags: Microsoft.DocumentDB/databaseAccounts, Microsoft.DocumentDB/databaseAccounts/sqlDatabases, Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers`
