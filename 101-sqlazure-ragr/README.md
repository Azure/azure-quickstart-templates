# SQL Azure Read-Access Georeplication

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjustinbarias%2Fazure-quickstart-templates%2Fmaster%2F101-sqlazure-ragr%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fjustinbarias%2Fazure-quickstart-templates%2Fmaster%2F101-sqlazure-ragr%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Azure SQL allows creation of databases as either of the following:
+ Default - Indicates that a new database is created with no data.
+ Copy - Indicates that a copy of the specified source database is created.
+ NonReadableSecondary - Indicates that a secondary database is created as a non-readable geo-replica of the specified source database. For more information about configuring a geo-replicated secondary database [here](https://azure.microsoft.com/documentation/articles/sql-database-business-continuity/)
+ OnlineSecondary- Indicates that a secondary database is created as a geo-replica of the specified source database. For more information about configuring a geo-replicated secondary database, see [here](https://azure.microsoft.com/documentation/articles/sql-database-business-continuity/)
+ PointInTimeRestore - Indicates that a database is created by restoring the specified source database.
+ Recovery - Indicates that a database is created by recovering the latest full and differential backups of the specified source database.
+ Restore - Indicates that a database is created by restoring the specified dropped source database.

This template will deploy a single Azure SQL Server, with a single Azure SQL DB - which is a georeplicated copy of an existing Azure SQL DB.

## Prerequisites

+ Azure Subscription (if you don’t have one you can create one [here](https://azure.microsoft.com/en-us/free/))
+ A pre-existing Azure SQL Server and Database in a different Azure Region 


## How do I get started?

1. We leverage the Azure Resource Manager (ARM) templates to configure this solution. You find the SQL Azure ARM Template [here](https://azure.microsoft.com/en-us/documentation/templates/101-sqlazure-oms-monitoring/).
2. Click the button that says ‘**Deploy to Azure**’. This will launch the ARM Template you need to configure in the Azure Portal. You need to specify the following parameters:
    + primaryDBResourceGroup - resource group where primary SQL Server is located
    + primarySQLServerName - Name of primary SQL Server Name
    + primarySQLDBName  Name of primary SQL Server Database
    + copyServerName - Name of new SQL Server copy 
    + copyDBName - Name of new SQL Database copy
    + sqlServerAdminPassword  - password of new SQL server 
 
 ![all text](images/01sqlazure.png "SQL Azure") 
  

