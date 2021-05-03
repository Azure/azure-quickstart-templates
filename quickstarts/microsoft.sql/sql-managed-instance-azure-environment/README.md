# SQL Managed Instance Virtual Network Environment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-managed-instance-azure-environment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-managed-instance-azure-environment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-managed-instance-azure-environment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-managed-instance-azure-environment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-managed-instance-azure-environment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-managed-instance-azure-environment/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-managed-instance-azure-environment%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-managed-instance-azure-environment%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-managed-instance-azure-environment%2Fazuredeploy.json)

This template allows you to create an Azure networking environment required to deploy [Azure SQL Database Managed Instances](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance) - fully managed SQL Server Database Engine hosted in the Azure cloud.

`Tags: Azure, SqlDb, Managed Instance, VNet`

## Solution overview and deployed resources

This deployment will create a configured Azure Virtual Network with two subnets - one that will be dedicated to your SQL Managed Instances,
and the another one where you can place other resources (for example VMs, App Service environments, etc.). This is a properly
configured networking environment where you can deploy Azure SQL Database Managed Instances.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo, and populate following parameters:
 - Name of the Azure Virtual Network that will be created and configured, including the address range that will be associated to this VNet. Default address range is 10.0.0.0/16 but you should probably change it to fit your needs.
 - Name of the default subnet where you can place the resources other than Managed Instances. The name will be "Default", if you don't want to change it. This is the subnet where you will place VMs or web apps that should access Managed Instances in your VNet. You should also enter address range that should be associated to this network. If you don't need any other resources in your VNet you can delete this subnet later. 
 - Name of the subnet that will be dedicated to Managed Instances placed in your VNet including the subnet address range (this is Azure SQL Managed Instance specific requirement). Choose carefully the subnet address range because it depends on the number of instances that you would like to place in the subnet. You would need at least two addresses per every General Purpose Managed Instance that you want to deploy in the subnet.
 - Name of the route table that will enable Managed Instance in the subnet to communicate with the Azure Management service that controls them. If the route table with the specified name doesn't exist the new one will be created and configured, otherwise the existing one will be used. The recommendation is to create one route table and don't change it.


