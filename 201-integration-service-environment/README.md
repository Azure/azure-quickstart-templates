# Provision an Integration Service Environment with a VNET, subnets, and managed connectors

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-integration-service-environment%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-integration-service-environment%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Overview

This template creates a VNET with four subnets then deploys an Integration Service Environment and selected managed connectors.

This template deploys the following resources:

- Virtual Network
- Four Subnets
- Integration Service Environment
  - Managed Connectors

## Managed Connectors

All native connectors will be available by default in ISE. Refer to [documentation](https://docs.microsoft.com/en-us/azure/logic-apps/connect-virtual-network-vnet-isolated-environment-overview#isolated-versus-global) to learn more about ISE specific Managed Connectors. These need to be specifically deployed into the ISE to be available (with the ISE label) in the Logic Apps editor. At the time of creation of this template, the possible list of values for the `managedConnectors` template parameter are:

| Value       | Connector         |
|:---------------------------------------- |:----------------------------------------------------- |
| sql | [SQL Server](https://docs.microsoft.com/en-us/connectors/sql/) |
| ftp | [FTP](https://docs.microsoft.com/en-us/connectors/ftp/) |
| azureblob | [Azure Blob Storage](https://docs.microsoft.com/en-us/connectors/azureblob/) |
| azurefile | [Azure File Storage](https://docs.microsoft.com/en-us/connectors/azurefile/) |
| azurequeues | [Azure Queues](https://docs.microsoft.com/en-us/connectors/azurequeues/) |
| azuretables | [Azure Table Storage](https://docs.microsoft.com/en-us/connectors/azuretables/) |
| sftpwithssh | [SFTP - SSH](https://docs.microsoft.com/en-us/connectors/sftpwithssh/) |
| edifact | [EDIFACT](https://docs.microsoft.com/en-us/connectors/edifact/) |
| x12 | [X12](https://docs.microsoft.com/en-us/connectors/x12/) |
| servicebus | [Service Bus](https://docs.microsoft.com/en-us/connectors/servicebus/) |
| documentdb | [Cosmos DB](https://docs.microsoft.com/en-us/connectors/documentdb/) |
| eventhubs | [Event Hubs](https://docs.microsoft.com/en-us/connectors/eventhubs/) |
| mq | [IBM WebSphere MQ](https://docs.microsoft.com/en-us/connectors/mq/) |
| sqldw | [SQL Data Warehouse](https://docs.microsoft.com/en-us/connectors/sqldw/) |
| db2 | [DB2](https://docs.microsoft.com/en-us/connectors/db2/) |
| smtp | [SMTP](https://docs.microsoft.com/en-us/connectors/smtp/) |
| si3270 | [IBM 3270](https://docs.microsoft.com/en-us/connectors/si3270/) |

## Miscellaneous

* This template does not deploy a Network Security Group and NSG rules. Review [the documentation](https://docs.microsoft.com/en-us/azure/logic-apps/connect-virtual-network-vnet-isolated-environment#check-network-ports) on recommendations for filtering traffic in your virtual network.

``Tags: logic-apps, ise, vnet``
