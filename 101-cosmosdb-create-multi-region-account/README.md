# Create a Multi-Region Azure Cosmos DB Database Account

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-multi-region-account%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-multi-region-account%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will create an Azure Cosmos DB Database Account with the two specifed regions, the provided name, and the Offer Type set to ***Standard***.

By not setting the optional Default Consistency Level parameter, the account will be created with the default consistency level of ***Session***. To set the Default Consistency Level to another value, see [101-create-documentdb-account-consistencypolicy](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-documentdb-account-consistencypolicy).

This template creates a database account with only one read region. To create the database account with more than one read region, add it to the 'locations' array in the azuredeploy.json file. Failover priority values must be unique and greater than 0 for read regions.
