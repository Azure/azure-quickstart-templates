# Create a new Web App, SQL Database, and Azure Redis Cache instance

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fredis-webapp-sql-on-azure%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates a new Web App, SQL Database, and Azure Redis Cache instance hosted in the Azure region of your choice.

The example expects the following parameters:

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Default value</th>
  </tr>
  <tr>
    <td>siteName</td>
    <td>DNS name of the new Web App.</td>
    <td></td>
  </tr>
  <tr>
    <td>hostingPlanName</td>
    <td>The name of the hosting plan for the new Web App.</td>
    <td></td>
  </tr>
  <tr>
    <td>siteLocation</td>
    <td>The location of the resources in this template.</td>
    <td></td>
  </tr>
  <tr>
    <td>sku</td>
    <td>The SKU of the Web App (Free, Shared, Basic, or Standard).</td>
    <td>Free</td>
  </tr>
  <tr>
    <td>workerSize</td>
    <td>The worker size of the Web App (0, 1, or 2).</td>
    <td>0</td>
  </tr>
  <tr>
    <td>redisCacheName</td>
    <td>The name of the new Azure Redis Cache instance.</td>
    <td></td>
  </tr>
  <tr>
    <td>redisCacheSKU</td>
    <td>The cache offering of the new Azure Redis Cache instance (Basic or Standard).</td>
    <td>Basic</td>
  </tr>
  <tr>
    <td>redisCacheFamily</td>
    <td>The Redis Cache family. 'C' is the only allowed value.</td>
    <td>C</td>
  </tr>
  <tr>
    <td>redisCacheCapacity</td>
    <td>The size of the new Azure Redis Cache instance. 0 = 250 MB, 1 = 1 GB, 2 = 2.5 GB, 3 = 6 GB, 4 = 13 GB, 5 = 26 GB, 6 = 53 GB.</td>
    <td>0</td>
  </tr>
  <tr>
    <td>redisCacheVersion</td>
    <td>The Redis server version for the new cache. 2.8 is the only allowed value.</td>
    <td>2.8</td>
  </tr>
  <tr>
    <td>SqlServerName</td>
    <td>Name of your SQL Server.</td>
    <td></td>
  </tr>
  <tr>
    <td>administratorLogin</td>
    <td>Admin username for SQL Database.</td>
    <td></td>
  </tr>
  <tr>
    <td>administratorLoginPassword</td>
    <td>Admin password for SQL Database.</td>
    <td></td>
  </tr>
  <tr>
    <td>databaseName</td>
    <td>Name of your SQL Database.</td>
    <td></td>
  </tr>
  <tr>
    <td>collation</td>
    <td>SQL collation name for your database.</td>
    <td>SQL_Latin1_General_CP1_CI_AS</td>
  </tr>
  <tr>
    <td>edition</td>
    <td>The SQL Database edition (Basic, Standard, or Premium).</td>
    <td>Basic</td>
  </tr>
  <tr>
    <td>maxSizeBytes</td>
    <td>The maximum size of the new database, in bytes.</td>
    <td>1073741824</td>
  </tr>
  <tr>
    <td>requestedServiceObjectiveId</td>
    <td></td>
    <td>910b4fcb-8a29-4c3e-958f-f7ba794388b2</td>
  </tr>
</table>

## For more information
-	[Azure Redis Cache documentation](http://azure.microsoft.com/documentation/services/redis-cache/)
-	[Web Apps documentation](http://azure.microsoft.com/documentation/services/app-service/web/)
	-	[Web App hosting plans](http://blogs.msdn.com/b/benjaminperkins/archive/2014/10/01/azure-website-hosting-plans-whp.aspx)
-	[SQL Database documentation](http://azure.microsoft.com/documentation/services/sql-database/)