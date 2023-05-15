---
description: This template creates an Azure Cosmos DB account for Core (SQL) API and a container with a stored procedure, trigger and user defined function.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: cosmosdb-sql-container-sprocs
languages:
- json
- bicep
---
# Create Azure Cosmos DB Core (SQL) API stored procedures

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-sql-container-sprocs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-sql-container-sprocs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-sql-container-sprocs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-sql-container-sprocs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-sql-container-sprocs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-sql-container-sprocs/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-sql-container-sprocs/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-sql-container-sprocs%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-sql-container-sprocs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-sql-container-sprocs%2Fazuredeploy.json)

This template creates an Azure Cosmos account for Core (SQL) API and a container with a stored procedure, trigger and user defined function.

Below are the parameters which can be user configured in the parameters file including:

- **Consistency Level:** Select from one of the 5 consistency levels: Strong, Bounded Staleness, Session, Consistent Prefix, Eventual.
- **Primary-Region:** Enter location for primary region.
- **System Managed Failover:** Select whether to enable system managed failover on the account.
- **Database Name:** Enter the database name for the account.
- **Container Name:** Enter the name for the container.
- **Throughput:** Enter the RU/s for the container (default is 400).

`Tags: Microsoft.DocumentDB/databaseAccounts, Microsoft.DocumentDB/databaseAccounts/sqlDatabases, Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers, Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/storedProcedures, Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/triggers, Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/userDefinedFunctions`
