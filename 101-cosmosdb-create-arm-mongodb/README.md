# Create an Azure Cosmos DB MongoDB API account

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-arm-mongo%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-arm-mongo%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates an Azure Cosmos DB MongoDB API account with the provided name, and the offer type set to `Standard`.

By not setting the optional consistency level parameter `consistencyLevel`, the account will be created with the default consistency level of `Session`.
To set the consistency level to another value, see [101-create-documentdb-account-consistencypolicy](https://github.com/Azure/azure-quickstart-templates/tree/master/101-documentdb-account-consistencypolicy-create).
