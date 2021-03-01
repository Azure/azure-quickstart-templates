# Azure Sql Database Managed Instance (SQL MI) with JumpBox Creation inside New Virtual Network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-sqlmi-new-vnet-w-jumpbox/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-sqlmi-new-vnet-w-jumpbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-sqlmi-new-vnet-w-jumpbox/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-sqlmi-new-vnet-w-jumpbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-sqlmi-new-vnet-w-jumpbox/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-sqlmi-new-vnet-w-jumpbox/CredScanResult.svg)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sqlmi-new-vnet-w-jumpbox%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sqlmi-new-vnet-w-jumpbox%2Fazuredeploy.json)

This template allows you to create a [Azure SQL Database Managed Instances](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance) inside a new virtual network with Virtual Machine that comes with the latest version of SQL Server Management Studio (SSMS) preinstalled.

`Tags: Azure, SqlDb, Managed Instance, SSMS`

## Solution overview and deployed resources

This deployment will create an Azure Virtual Network with two subnets _ManagedInstance_ and _Management_. Managed Instance will be deployed in _ManagedInstance_ subnet. Virtual machine with the latest version of SQL Server Management Studio (SSMS) will be deployed in _Management_ subnet.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo, and populate following parameters:
 - Name of the Managed Instance that will be create including Managed Instance admin name and password
 - Name of the Azure Virtual Network that will be created and configured, including the address range that will be associated to this VNet. Default address range is 10.0.0.0/16 but you could change it to fit your needs.
 - Name of the subnet where Managed Instance will be created. The name will be _ManagedInstance_, if you don't want to change it. Default address range is 10.0.0.0/24 but you could change it to fit your needs.
 - Name of the subnet where VM with SSMS will be created. The name will be _Management_, if you don't want to change it. Default address range is 10.0.1.0/24 but you could change it to fit your needs.
 - Sku name that combines service tear and hardware generation, number of virtual cores and storage size in GB. The table below shows supported combinations.
 - License type that could be _BasePrice_ if you are eligable for [Azure Hybrid Use Benefit for SQL Server](https://azure.microsoft.com/en-us/pricing/hybrid-benefit/) or _LicenseIncluded_ otherwise

||GP_Gen4|GP_Gen5|BC_Gen4|BC_Gen5|
|----|------|-----|------|-----|
|Tier|General Purpose|General Purpose|Business Critical|Busines Critical|
|Hardware|Gen 4|Gen 5|Gen 4|Gen 5|
|Min vCores|8|8|8|8|
|Max vCores|24|80|32|80|
|Min storage size|32|32|32|32|
|Max storage size|8192|8192|1024|1024 GB for 8, 16 vCores<br/>2048 GB for 24 vCores<br/>4096 GB for 32, 40, 64, 80 vCores|

## Important

During the public preview deployment might take up to 6h. This is because virtual cluster that hosts the instances needs some time to deploy. Each subsequent instance creation in the same virtual cluster takes just about a few minutes.

After the last Managed Instance is deprovisioned, cluster stays a live for up to 24h. This is to avoid waiting for a new cluster to be provisioned in case that customer just wants to recreate the instance. During that period of time Resource Group and virtual network could not be deleted. This is a known issue and Managed Instance team is working on resolving it.




