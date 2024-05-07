---
description: This template creates an Azure Cosmos DB account for MongoDB API 4.2 in two regions showing mixed autoscale throughput usage.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: cosmosdb-mongodb-autoscale
languages:
- json
- bicep
---
# Create an Azure Cosmos account for MongoDB API autoscale

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-mongodb-autoscale/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-mongodb-autoscale/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-mongodb-autoscale/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-mongodb-autoscale/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-mongodb-autoscale/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-mongodb-autoscale/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-mongodb-autoscale/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-mongodb-autoscale%2Fazuredeploy.json)
[![Deploy To Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-mongodb-autoscale%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-mongodb-autoscale%2Fazuredeploy.json)

This template creates an Azure Cosmos account for MongoDB API with server-version 4.2, provisioned for two regions. This template also demonstrates the use of shared and dedicated throughput, using shared throughput on a *products* collection and dedicated throughput on a *orders* collection for better performance and scale. Shared throughput can be shared with up to 25 collections within a database and is more efficient for scenarios with large numbers of collections where performance and scale are not critical. Dedicated throughput should be used for collections that require predictable performance and scale. This usage represents a best practice when using Cosmos DB.

Below are the parameters which can be user configured in the parameters file including:

- **Account Name:** Enter the account name. Must be globally unique.
- **Primary Region:** Enter locations for primary region.
- **Secondary Region:** Enter locations for secondary region.
- **Server Version:** Select the MongoDB server version (default is 4.2).
- **Database Name:** Enter the database name for the account.
- **Shared Autoscale Max Throughput:** Enter the autoscale max RU/s to share across collections in the database that are not provisioned with their own throughput (default and minimum is 1000).
- **Collection 1 Name:** Enter the name for the first collection with shared database throughput, default is *products*.
- **Collection 2 Name:** Enter the name for the second collection with dedicated throughput, default is *orders*.
- **Dedicated Autoscale Max Throughput:** Enter the autoscale RU/s dedicated for *Collection 2* (default and minimum is 1000).

`Tags: Microsoft.DocumentDB/databaseAccounts, Microsoft.DocumentDB/databaseAccounts/mongodbDatabases, Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections`
