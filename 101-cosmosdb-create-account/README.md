# Create an Azure CosmosDB Account
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-create-account%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

This ARM template is intented to create a **CosmosDB Account** quickly with the **minimal required values**

`Tags : CosmosDB`

## Parameters
The following parameters has default value allowing to deploy the template as-is without providing any parameter but could be overriden at the deployment time :

`name` : Name of the CosmosDB Account, default is a unique string calculated from the "cosmosdb" token and the resource group id.  

`location` : Location of the CosmosDB Account, default to the location of the resource group.  

`tier` : Offering type of the CosmosDB Account, default to Standard.