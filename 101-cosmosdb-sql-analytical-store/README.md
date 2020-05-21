# Create an Azure Cosmos DB account for Core (SQL) API with autoscale and analytical store

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-sql-analytical-store/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-sql-analytical-store/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-sql-analytical-store/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-sql-analytical-store/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-sql-analytical-store/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-sql-analytical-store/CredScanResult.svg)

This template creates an Azure Cosmos account for Core (SQL) API with a database and container configured with autoscale and analytical store.

Below are the parameters which can be user configured in the parameters file or template including:

- **Account Name:** Enter the account name for the Cosmos account.
- **Location:** Enter location for the primary write region.
- **Database Name:** Enter the database name for the account.
- **Container Name:** Enter the name for the container for the account.
- **Partition Key Path:** Enter the path for the partition key for the container.
- **Throughput Policy:** Select Manual or Autoscale throughput policy.
- **Manual Provisioned Throughput:** Enter the RU/s for the container when Throughput Policy is Manual (default 400).
- **Autoscale Max Throughput:** Enter the maximum RU/s for the container when Throughput Policy is Autoscale (default 4000).

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-sql-analytical-store%2Fazuredeploy.json)  
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-sql-analytical-store%2Fazuredeploy.json)
