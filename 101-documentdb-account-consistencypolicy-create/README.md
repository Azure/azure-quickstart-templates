# Create DocumentDB Account with a specified Consistency Policy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-documentdb-account-consistencypolicy-create%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-documentdb-account-consistencypolicy-create%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will create a DocumentDB Account with the name provided, the location set to the same location as the resource group that was used, and the Offer Type set to ***Standard***.

This template includes the optional Consistency Policy property, the account will be created with the default consistency level specified.

For more information on DocumentDB Consistency Levels please refer to, [Using consistency levels to maximize availability and performance in DocumentDB](https://azure.microsoft.com/en-us/documentation/articles/documentdb-consistency-levels/)

If you want just want to create a DocumentDB with the default values set then refer to, [101-create-documentdb-account](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-documentdb-account) to see how it is done.

