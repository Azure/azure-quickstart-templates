# Create a Single-Region Azure Cosmos DB account for any API Type

This template will create an Azure Cosmos DB account in a single region and provides multiple different configurations including:

- **API Type:** Select from any of the supported API types including: SQL, Cassandra, Gremlin, MongoDB, or Table.
- **Consistency Level:** Select from one of the 5 consistency levels: Strong, Bounded Staleness, Session, Consistent Prefix, Eventual.
- **Multi-Master:** Select whether to enable multi-master support. Not recommended if not adding additional regions.
- **Automatic Failover:** Select whether to enable automatic failover on the account (Ignored when Multi-Master is enabled).

The location for the single primary region is derived from the resource group the Cosmos DB account resource is provisioned in. After provisioning the account and single region, users can add additional regions to replicate to.


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarkjbrown%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-arm-template%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-arm-template%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-arm-template%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
