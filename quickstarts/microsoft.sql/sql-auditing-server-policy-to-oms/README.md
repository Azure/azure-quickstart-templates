# Deploy an Azure SQL Server with Auditing enabled to write audit logs to Log Analytics

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-auditing-server-policy-to-oms/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-auditing-server-policy-to-oms/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-auditing-server-policy-to-oms/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-auditing-server-policy-to-oms/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-auditing-server-policy-to-oms/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-auditing-server-policy-to-oms/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-auditing-server-policy-to-oms%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-auditing-server-policy-to-oms%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-auditing-server-policy-to-oms%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-auditing-server-policy-to-oms%2Fazuredeploy.json)

This template allows you to deploy an Azure SQL server with Auditing enabled to write audit logs to Log Analytics (OMS workspace)

In order to send audit events to Log Analytics, set auditing settings with 'Enabled' state and set 'IsAzureMonitorTargetEnabled' as true.
Also, configure Diagnostic Settings with 'SQLSecurityAuditEvents' diagnostic logs category on the 'master' database (for server level auditing).

Auditing for Azure SQL Database and Azure Synapse Analytics tracks database events and writes them to an audit log in your Azure storage account, Log Analytics workspace or Event Hubs.

For more information on SQL database auditing, see the [official documentation]( https://docs.microsoft.com/azure/sql-database/sql-database-auditing).

Enable Auditing of Microsoft support operations (isMSDevOpsAuditEnabled) to tracks Microsoft support engineers'(DevOps) operations on your server and write them to an audit log in your Log Analytics.

For more information on Auditing of Microsoft support operations, see the [official documentation]( https://docs.microsoft.com/azure/azure-sql/database/auditing-overview#auditing-of-microsoft-support-operations).
