# Deploy an Azure SQL Server with Auditing enabled to write audit logs to Log Analytics

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-oms/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-oms/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-oms/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-oms/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-oms/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-oms/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sql-auditing-server-policy-to-oms%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sql-auditing-server-policy-to-oms%2Fazuredeploy.json)

This template allows you to deploy an Azure SQL server with Auditing enabled to write audit logs to Log Analytics (OMS workspace) 

In order to send audit events to Log Analytics, set auditing settings with 'Enabled' state and set 'IsAzureMonitorTargetEnabled' as true.
Also, configure Diagnostic Settings with 'SQLSecurityAuditEvents' diagnostic logs category on the 'master' database (for server level auditing).

Auditing for Azure SQL Database and SQL Data Warehouse tracks database events and writes them to an audit log in your Azure storage account, OMS workspace or Event Hubs.

For more information on SQL database auditing , see the [official documentation]( https://docs.microsoft.com/en-us/azure/sql-database/sql-database-auditing).


