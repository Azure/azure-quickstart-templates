# Migrate to Azure SQL database using Azure Database Migration Service

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azure-database-migration-service%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azure-database-migration-service%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

For more details about the service please follow the link https://azure.microsoft.com/en-us/services/database-migration/

The above template will deploy a resource group with the below resources in your subscription.
1) An Azure Database Migration Service
2) A Windows 2016 server VM with SQL server installed with a pre-created database on the server.
3) A Target Azure SQL database server with pre-created schema of the source database on the target server.
4) A virtual network to which the source and DMS service will be connected.

Using the above resources you can connect to source and target servers, select the databases to migrate and run an end-to-end migration.
