# Deploy an Azure SQL Server with Auditing enabled to write audit logs to Event Hubs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sql-auditing-server-policy-to-eventhub%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-sql-auditing-server-policy-to-eventhub%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy an Azure SQL server with Aduiting enabled to write audit logs to an exiting Event Hub.

In order to send audit events to Event Hub, set auditing settings with 'Enabled' 'State' and set 'IsAzureMonitorTargetEnabled' as true.
Also, configure Diagnostic Settings with 'SQLSecurityAuditEvents' diagnostic logs category on the 'master' database (for serve level auditing).

Auditing for Azure SQL Database and SQL Data Warehouse tracks database events and writes them to an audit log in your Azure storage account, OMS workspace or Event Hubs.

For more information on SQL database auditing , see the [official documentation]( https://docs.microsoft.com/en-us/azure/sql-database/sql-database-auditing).
