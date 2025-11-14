---
description: This template allows you to create a network security group, a virtual network and an Azure Databricks workspace with the virtual network, and Private Endpoint.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway
languages:
- bicep
- json
---
# Azure Databricks All-in-one Template VNetInjection-Pvtendpt

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.databricks/databricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.databricks%2Fdatabricks-all-in-one-template-for-vnet-injection-privateendpoint-with-nat-gateway%2Fazuredeploy.json)

This template allows you to create a network security group, a Virtual Network and an Azure Databricks Workspace with Virtual Network, and Private Endpoint.
For more information, see the [Azure Databricks Documentation](https://docs.microsoft.com/azure/azure-databricks/).

### What is Azure Databricks?

Azure Databricks is an Apache Spark-based analytics platform optimized for the Microsoft Azure cloud services platform. Designed with the founders of Apache Spark, Databricks is integrated with Azure to provide one-click setup, streamlined workflows, and an interactive workspace that enables collaboration between data scientists, data engineers, and business analysts.

Azure Databricks is a fast, easy, and collaborative Apache Spark-based analytics service. For a big data pipeline, the data (raw or structured) is ingested into Azure through Azure Data Factory in batches, or streamed near real-time using Kafka, Event Hub, or IoT Hub. This data lands in a data lake for long term persisted storage, in Azure Blob Storage or Azure Data Lake Storage. As part of your analytics workflow, use Azure Databricks to read data from multiple data sources such as Azure Blob Storage, Azure Data Lake Storage, Azure Cosmos DB, or Azure SQL Data Warehouse and turn it into breakthrough insights using Spark.

This template allows you to install the following options

+ Databricks 14 day trial
+ Databricks Standard
+ Databricks Premium

### Databricks Resources

[Getting Started with Databricks](https://docs.microsoft.com/azure/databricks/getting-started/index)
[Databricks Admin Guide](https://docs.azuredatabricks.net/administration-guide/index.html)

### Microsoft Learn Modules

[Databricks Microsoft Learn Modules](https://docs.microsoft.com/learn/browse/?term=Databricks)

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Databricks/workspaces, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`
