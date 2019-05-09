# Create an Azure Cosmos DB containers for Core (SQL) API with two containers

This template creates an Azure Cosmos account for Core (SQL) API in two region regions with 2 containers that share throughput of 400 RU/s set at the database-level and one container that has dedicated throughput of 400 RU/s for a total RU/s for this deployment at 800 RU/s.

Below are the parameters which can be user configured in the parameters file including:

- **Consistency Level:** Select from one of the 5 consistency levels: Strong, Bounded Staleness, Session, Consistent Prefix, Eventual.
- **Multi-Region:** Enter locations for primary and secondary regions.
- **Multi-Master:** Select whether to enable multi-master support making both regions fully writable.
- **Automatic Failover:** Select whether to enable automatic failover on the account (Ignored when Multi-Master is enabled).
- **Database Name:** Enter the database name for the account.
- **Shared Throughput:** Enter the RU/s to share across the 2 containers (default is 400).
- **Shared Container 1 Name:** Enter the name for the first container with shared throughput.
- **Shared Container 2 Name:** Enter the name for the second container with shared throughput.
- **Dedicated Throughput:** Enter the RU/s for the container with dedicated throughput (default is 400).
- **Dedicated Container 1 Name:** Enter the name for the container with dedicated throughput.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-sql-mixed-ru%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-sql-mixed-ru%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
