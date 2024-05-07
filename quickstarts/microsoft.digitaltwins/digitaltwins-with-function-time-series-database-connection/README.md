---
description: This template creates an Azure Digital Twins instance configured with a time series data history connection. In order to create a connection, other resources must be created such as an Event Hubs namespace, an event hub, Azure Data Explorer cluster, and a database. Data is sent to an event hub which eventually forwards the data to the Azure Data Explorer cluster. Data is stored in a database table in the cluster
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: digitaltwins-with-function-time-series-database-connection
languages:
- bicep
- json
---
# Azure Digital Twins with Time Data History Connection

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.digitaltwins/digitaltwins-with-function-time-series-database-connection/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.digitaltwins%2Fdigitaltwins-with-function-time-series-database-connection%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.digitaltwins%2Fdigitaltwins-with-function-time-series-database-connection%2Fazuredeploy.json)  

This template creates an Azure Digital Twins instance with a time series data history connection. Other resources are also created such as an Event Hubs namespace, an event hub, an Azure Data Explorer cluster, and a database.
For more information about how data history works, see the following: [Data History Documentation](https://docs.microsoft.com/en-us/azure/digital-twins/concepts-data-history).`Tags: ``Tags: `