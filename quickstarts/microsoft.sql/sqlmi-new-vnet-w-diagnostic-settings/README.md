---
description: This template allows you to deploy SQL MI and additional resources used for storing logs and metrics (diagnostic workspace, storage account, event hub).
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sqlmi-new-vnet-w-diagnostic-settings
languages:
- json
---
# Create SQL MI with configured sending of logs and metrics.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-new-vnet-w-diagnostic-settings/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-new-vnet-w-diagnostic-settings/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-new-vnet-w-diagnostic-settings/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-new-vnet-w-diagnostic-settings/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-new-vnet-w-diagnostic-settings/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-new-vnet-w-diagnostic-settings/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsqlmi-new-vnet-w-diagnostic-settings%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsqlmi-new-vnet-w-diagnostic-settings%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsqlmi-new-vnet-w-diagnostic-settings%2Fazuredeploy.json)

This template allows you to create an [Azure SQL Managed Instance](https://docs.microsoft.com/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview) inside a new virtual network, and also creates diagnostic workspace, storage account, and event hub for storing diagnostic logs. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/azure-sql/managed-instance/create-template-quickstart) article.

`Tags: Azure, SqlDb, Managed Instance, Event Hub, Diagnostic, Microsoft.Network/networkSecurityGroups, Microsoft.Network/routeTables, Microsoft.Network/virtualNetworks, Microsoft.Sql/managedInstances, SystemAssigned, Microsoft.EventHub/namespaces, eventhubs, Microsoft.Storage/storageAccounts, Microsoft.OperationalInsights/workspaces, Microsoft.Insights/diagnosticSettings`

## Solution overview and deployed resources

This deployment creates an Azure Virtual Network with a properly configured _ManagedInstance_ subnet and deploys a Managed Instance inside. Other deployed resources include event hub, diagnostic workspace and storage account are deployed for the purpose of sending and storing diagnostic logs.

## Deployment steps

You can select the **Deploy to Azure** button at the beginning of this document. Or, follow the instructions for command line deployment using the scripts in the root of this repository, and populate the following parameters:

- Name of the Managed Instance that will be created including Managed Instance administrator name and password.
- Name of the Azure Virtual Network that will be created and configured, including the address range that will be associated to this VNet. The default address range is `10.0.0.0/16` but you can change it to fit your needs.
- Name of the subnet where the Managed Instance will be created. If you don't change the name, it will be _ManagedInstance_. The default address range is `10.0.0.0/24` but you can change it to fit your needs.
- Sku name that combines service tier and hardware generation, number of virtual cores and storage size in GB. The table below shows supported combinations.
- License type of _BasePrice_ if you're eligible for [Azure Hybrid Use Benefit for SQL Server](https://azure.microsoft.com/pricing/hybrid-benefit/) or _LicenseIncluded_.

||GP_Gen5|BC_Gen5|
|----|------|------|
|Tier|General Purpose|Busines Critical|
|Hardware|Gen 5|Gen 5|
|Min vCores|8|8|
|Max vCores|80|80|
|Min storage size|32|32|
|Max storage size|8192|1024 GB for 8, 16 vCores<br/>2048 GB for 24 vCores<br/>4096 GB for 32, 40, 64, 80 vCores|

- Name for the diagnostic settings configuration
- Name for the log analytics workspace where logs will be sent
- Name for the storage account that will be used for sending logs
- Event hub name, Event hub namespace name and event hub authorization rule name for confguring environment for storing logs in an event hub

## Important

Deployment of first instance in the subnet might take up to six hours, while subsequent deployments take up to 1.5 hours. This is because a virtual cluster that hosts the instances needs time to deploy or resize the virtual cluster. For more details visit [Overview of Azure SQL Managed Instance management operations](https://docs.microsoft.com/azure/azure-sql/managed-instance/management-operations-overview)

Each virtual cluster is associated with a subnet and deployed together with first instance creation. In the same way, a virtual cluster is [automatically removed together with last instance deletion](https://docs.microsoft.com/azure/azure-sql/managed-instance/virtual-cluster-delete) leaving the subnet empty and ready for removal.
