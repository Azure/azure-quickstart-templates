---
description: Deploy Azure Data Explorer DB with Cosmos DB connection.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: kusto-cosmos-db
languages:
- bicep
- json
---
# Deploy Azure Data Explorer DB with Cosmos DB connection

![Fairfax Deployment](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/FairfaxDeployment.svg)
![Fairfax Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/FairfaxLastTestDate.svg)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/PublicDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-cosmos-db%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-cosmos-db%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-cosmos-db%2Fazuredeploy.json)

https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-cosmos-db/BicepVersion.svg

This template allows you to deploy an Azure Data Explorer cluster with System Assigned Identity, a database, an Azure Cosmos DB account (NoSQL), an Azure Cosmos DB database, an Azure Cosmos DB container and a data connection between the Cosmos DB container and the Kusto database (using the system assigned identity).

This template was authored in bicep (see [bicep template](main.bicep)), referring a [KQL script](script.kql) and then transpiled into [JSON template](azuredeploy.json).

`Tags: Microsoft.Kusto/clusters/databases/scripts, Microsoft.Kusto/clusters/databases/dataConnections, Microsoft.Kusto/clusters/databases, Microsoft.Kusto/clusters, SystemAssigned, Microsoft.Authorization/roleAssignments`
