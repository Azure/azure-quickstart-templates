# Azure SQL Managed Instance (SQL MI) creation inside new virtual network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-sqlmi-new-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-sqlmi-new-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-sqlmi-new-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-sqlmi-new-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-sqlmi-new-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-sqlmi-new-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sqlmi-new-vnet%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sqlmi-new-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sqlmi-new-vnet%2Fazuredeploy.json)

This template allows you to create an [Azure SQL Managed Instance](https://docs.microsoft.com/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview) inside a new virtual network. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/azure-sql/managed-instance/create-template-quickstart) article.

`Tags: Azure, SqlDb, Managed Instance`

## Solution overview and deployed resources

This deployment creates an Azure Virtual Network with a properly configured _ManagedInstance_ subnet and deploys a Managed Instance inside.

## Deployment steps

You can select the **Deploy to Azure** button at the beginning of this document. Or, follow the instructions for command line deployment using the scripts in the root of this repository, and populate the following parameters:

- Name of the Managed Instance that will be created including Managed Instance administrator name and password.
- Name of the Azure Virtual Network that will be created and configured, including the address range that will be associated to this VNet. The default address range is `10.0.0.0/16` but you can change it to fit your needs.
- Name of the subnet where the Managed Instance will be created. If you don't change the name, it will be _ManagedInstance_. The default address range is `10.0.0.0/24` but you can change it to fit your needs.
- Sku name that combines service tier and hardware generation, number of virtual cores and storage size in GB. The table below shows supported combinations.
- License type of _BasePrice_ if you're eligible for [Azure Hybrid Use Benefit for SQL Server](https://azure.microsoft.com/pricing/hybrid-benefit/) or _LicenseIncluded_.

||GP_Gen4|GP_Gen5|BC_Gen4|BC_Gen5|
|----|------|-----|------|-----|
|Tier|General Purpose|General Purpose|Business Critical|Busines Critical|
|Hardware|Gen 4|Gen 5|Gen 4|Gen 5|
|Min vCores|8|8|8|8|
|Max vCores|24|80|32|80|
|Min storage size|32|32|32|32|
|Max storage size|8192|8192|1024|1024 GB for 8, 16 vCores<br/>2048 GB for 24 vCores<br/>4096 GB for 32, 40, 64, 80 vCores|

## Important

During the public preview deployment might take up to six hours. This is because a virtual cluster that hosts the instances needs time to deploy. Each subsequent instance creation in the same virtual cluster takes a few minutes.

After the last Managed Instance is deprovisioned, the cluster stays alive for up to 24 hours. This avoids waiting for a new cluster to be provisioned in case that customer just wants to recreate the instance. During that time period the resource group and virtual network can't be deleted. This is a known issue and the Managed Instance team is working on a resolution.
