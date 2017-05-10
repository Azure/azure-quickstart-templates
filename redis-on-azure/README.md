# Create a new Azure Redis Cache instance

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fredis-on-azure%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template creates a new Azure Redis Cache instance hosted in the Azure region of your choice.

The example expects the following parameters:

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Default value</th>
  </tr>
  <tr>
    <td>redisCacheName</td>
    <td>The name of the new Azure Redis Cache instance.</td>
    <td></td>
  </tr>
  <tr>
    <td>redisCacheLocation</td>
    <td>The location of the new Azure Redis Cache instance.</td>
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
</table>

## To run the script
-	[Provision Redis Cache](https://azure.microsoft.com/documentation/articles/cache-redis-cache-arm-provision/)

## For more information
-	[Azure Redis Cache documentation](http://azure.microsoft.com/documentation/services/redis-cache/)