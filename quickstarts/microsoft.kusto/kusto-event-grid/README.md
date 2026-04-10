---
description: Deploy Azure Data Explorer db with Event Grid connection.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: kusto-event-grid
languages:
- bicep
- json
---
# Deploy Azure Data Explorer db with Event Grid connection

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-grid/PublicLastTestDate.svg) 
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-grid/PublicDeployment.svg) 
![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-grid/FairfaxLastTestDate.svg) 
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-grid/FairfaxDeployment.svg) 
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-grid/BestPracticeResult.svg) 
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-grid/CredScanResult.svg) 
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kusto/kusto-event-grid/BicepVersion.svg) 
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-event-grid%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-event-grid%2Fazuredeploy.json) 
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kusto%2Fkusto-event-grid%2Fazuredeploy.json) 

This template allows you deploy a cluster with System Assigned Identity, a database, an Azure Storage Account, an Event hub, an Event Grid notification publishing notifications to Event Hubs and a data connection between the Azure Storage and the database (using the system assigned identity).

This template was authored in bicep (see [bicep template](main.bicep)), referring a [KQL script](script.kql) and then transpiled into [JSON template](azuredeploy.json).

Once the template is deployed, you should be able to copy a CSV text file into the `landing` container and it should be ingested automatically (through the Event Grid connection) in the table `People`.  You can try with a CSV of the form:

```
Name, Department
Alice,Finance
Bob,HR
Carl,Operations
```

`Tags: Microsoft.EventHub/namespaces/eventhubs/consumergroups, Microsoft.EventHub/namespaces/eventhubs, Microsoft.Kusto/clusters/databases/scripts, Microsoft.Kusto/clusters/databases/dataConnections, Microsoft.Kusto/clusters/databases, Microsoft.EventHub/namespaces, Microsoft.Kusto/clusters, SystemAssigned, Microsoft.Authorization/roleAssignments, Microsoft.EventGrid/systemTopics, Microsoft.EventGrid/systemTopics/eventSubscriptions`
