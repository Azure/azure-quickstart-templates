# Create two Premium tier Azure Cache for Redis instances with Virtual Networks and Geo-Replication

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-redis-vnet-geo-replication/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-redis-vnet-geo-replication/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-redis-vnet-geo-replication/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-redis-vnet-geo-replication/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-redis-vnet-geo-replication/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-redis-vnet-geo-replication/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f201-redis-vnet-geo-replication%2fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-redis-vnet-geo-replication%2Fazuredeploy.json)

Create two Premium tier Azure Cache for Redis instances inside separate Virtual Networks and linked with Geo-Replication by using a template. Virtual Network deployments provide enhanced security and isolation for your Cache instances, as well as isolation using subnets, access control policies, and other features to further restrict access to Azure Cache for Redis with a Virtual Network. Geo-replication provides additional availability to the application by linking two Premium tier Cache instances and replicating data from the primary cache to the secondary cache.

For information about using this template, see [How to configure Virtual Network Support for a Premium Azure Cache for Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-vnet) and [How to configure Geo-replication for Azure Cache for Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-geo-replication).


