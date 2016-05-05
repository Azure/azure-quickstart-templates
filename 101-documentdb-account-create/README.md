# Create DocumentDB Account

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-documentdb-account-create%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-documentdb-account-create%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will create a DocumentDB Account with the name provided, the location set to the same location as the resource group that was used, and the Offer Type set to ***Standard***.

By not setting the optional Default Consistency Level parameter, the account will be created with the default consistency level of ***Session***.
If you want to set the Default Consistency Level to another value refer to, [101-create-documentdb-account-consistencypolicy](https://github.com/Azure/azure-quickstart-templates/tree/master/101-create-documentdb-account-consistencypolicy) to see how it is done.

