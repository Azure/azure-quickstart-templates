# Azure Sql Database Managed Instance (SQL MI) Creation inside New Virtual Network
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sqlmi-new-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmaster%2Fazure-quickstart-templates%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a new VNet and deploys a **SQL MI** inside. For **SQL MI** overview visit: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance

## Important
**SQL MI** is still in gated public preview. Before deploying this template you have to whitelist your subscription as explained here: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance-create-tutorial-portal#whitelist-your-subscription. 

During the public preview deployment might take up to 48h. The reason why provisioning takes some time is that along the Managed Instance virtual cluster that hosts the instance is created. Each subsequent instance creation takes just about a few minutes.

After the last Managed Instance is deprovisioned, cluster stays a live for up to 24h. This is to avoid waiting for a new cluster to be provisioned in case that customer just wants to recreate the instance. During that period of time Resource Group and virtual network could not be deleted. This is a known issue and Managed Instance team is working on resolving it.


