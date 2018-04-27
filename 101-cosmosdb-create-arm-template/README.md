# Create an Azure Cosmos DB account for an API type

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-arm-template%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-arm-template%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates an Azure Cosmos DB API account with the provided API type and a generated database account name, and the offer type set to `Standard`. The API type can be one of `Cassandra`, `Gremlin`, `MongoDB`, `SQL`, or `Table`, for example:

```json
    "apiType": {
      "value": "Cassandra"
    },
```

By not setting the optional consistency level parameter `consistencyLevel`, the account will be created with the default consistency level of `Session`. To set the consistency level to another value, see [101-create-documentdb-account-consistencypolicy](https://github.com/Azure/azure-quickstart-templates/tree/master/101-documentdb-account-consistencypolicy-create).
