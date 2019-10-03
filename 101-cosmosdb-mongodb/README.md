# Create an Azure Cosmos account for MongoDB API with two collections

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-mongodb/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-mongodb/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-mongodb/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-mongodb/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-mongodb/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-mongodb/CredScanResult.svg" />&nbsp;

This template creates an Azure Cosmos account for MongoDB API, provisioned for two regions, then provision a database with throughput shared across 2 collections.

Below are the parameters which can be user configured in the parameters file including:

- **Consistency Level:** Select from one of the 5 consistency levels: Strong, Bounded Staleness, Session, Consistent Prefix, Eventual.
- **Multi-Region:** Enter locations for primary and secondary regions.
- **Multi-Master:** Select whether to enable multi-master support making both regions fully writable.
- **Automatic Failover:** Select whether to enable automatic failover on the account (Ignored when Multi-Master is enabled).
- **Database Name:** Enter the database name for the account.
- **Throughput:** Enter the Ru/s to share across the 2 containers (default is 400).
- **Collection 1 Name:** Enter the name for the first collection.
- **Collection 2 Name:** Enter the name for the second collection.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-mongodb%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-mongodb%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

