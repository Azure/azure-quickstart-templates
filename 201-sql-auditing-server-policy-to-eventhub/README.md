# Deploy an Azure SQL Server with Auditing enabled to write audit logs to Event Hubs

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-eventhub/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-eventhub/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-eventhub/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-eventhub/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-eventhub/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-sql-auditing-server-policy-to-eventhub/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sql-auditing-server-policy-to-eventhub%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sql-auditing-server-policy-to-eventhub%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy an Azure SQL server with Aduiting enabled to write audit logs to an exiting Event Hub.

In order to send audit events to Event Hub, set auditing settings with 'Enabled' 'State' and set 'IsAzureMonitorTargetEnabled' as true.
Also, configure Diagnostic Settings with 'SQLSecurityAuditEvents' diagnostic logs category on the 'master' database (for serve level auditing).

Auditing for Azure SQL Database and SQL Data Warehouse tracks database events and writes them to an audit log in your Azure storage account, OMS workspace or Event Hubs.

For more information on SQL database auditing , see the [official documentation]( https://docs.microsoft.com/en-us/azure/sql-database/sql-database-auditing).

