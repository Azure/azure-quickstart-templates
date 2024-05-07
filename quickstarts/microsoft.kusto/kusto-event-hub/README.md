---
description: Deploy Azure Data Explorer db with Event Hub connection.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: kusto-event-hub
languages:
- json
- bicep
---
# Deploy Azure Data Explorer db with Event Hub connection.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-event-hub%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-event-hub%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-event-hub%2Fazuredeploy.json)

https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-hub/BicepVersion.svg

This template allows you deploy a cluster with System Assigned Identity, a database, an Azure Event Hub and a data connection between the Event Hub and the database (using the system assigned identity).

This template was authored in bicep (see [bicep template](main.bicep)), referring a [KQL script](script.kql) and then transpiled into [JSON template](azuredeploy.json).

`Tags: Microsoft.EventHub/namespaces/eventhubs/consumergroups, Microsoft.EventHub/namespaces/eventhubs, Microsoft.Kusto/clusters/databases/scripts, Microsoft.Kusto/clusters/databases/dataConnections, Microsoft.Kusto/clusters/databases, Microsoft.EventHub/namespaces, Microsoft.Kusto/clusters, SystemAssigned, Microsoft.Authorization/roleAssignments`
