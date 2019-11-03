# Azure SQL Managed Instance with network security group and route tables

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/azure-sql-managed-instance/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/azure-sql-managed-instance/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/azure-sql-managed-instance/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/azure-sql-managed-instance/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/azure-sql-managed-instance/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/azure-sql-managed-instance/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fazure-sql-managed-instance%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjftl6y%2Fazure-quickstart-templates%2Fmaster%2Fazure-sql-managed-instance%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.png"/>
</a>

This template deploys an **Azure SQL Managed Instance** into Azure with an correct routes and NSGs per [Connectivity architecture for a managed instance in Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-connectivity-architecture).

---
**NOTE**

For the first instance in a subnet, deployment time is typically much longer than in the case of the subsequent instances and can take up to 6 hours to complete.

---

