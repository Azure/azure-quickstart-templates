# Create an Azure Cosmos account for Cassandra API with keyset and two tables

This template will create an Azure Cosmos account for Cassandra API, provisioned for two regions, then provision a keyset with shared throughput across two tables.

Below are the parameters which can be user configured in the parameters file including:

- **Consistency Level:** Select from one of the 5 consistency levels: Strong, Bounded Staleness, Session, Consistent Prefix, Eventual.
- **Multi-Region:** Enter locations for primary and secondary regions.
- **Multi-Master:** Select whether to enable multi-master support making both regions fully writable.
- **Automatic Failover:** Select whether to enable automatic failover on the account (Ignored when Multi-Master is enabled).
- **Keyset Name:** Enter the Keyset name for the account.
- **Throughput:** Enter the Ru/s to share across the 2 containers (default is 400).
- **Table 1 Name:** Enter the name for the first table.
- **Table 2 Name:** Enter the name for the second table.


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-cassandra%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-cassandra%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
