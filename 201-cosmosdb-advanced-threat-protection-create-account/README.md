# Deploy an Azure Storage Account with Advanced Threat Protection enabled

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-cosmosdb-advanced-threat-protection-create-account%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-cosmosdb-advanced-threat-protection-create-account/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This ARM template is intented to create a **CosmosDB Account** quickly with the **minimal required values** and **Advanced Threat Protection**.

CosmosDB Advanced Threat Protection is a unified package for advanced CosmosDB security capabilities.

For more information on CosmosDB Advanced Threat Protection, see the [official documentation](replace.with.official.documentation.link).

`Tags : CosmosDB, Advanced Threat Protection`

## Parameters
The following parameters has default value allowing to deploy the template as-is without providing any parameter but could be overriden at the deployment time :

`name` : Name of the CosmosDB Account, default is a unique string calculated from the "cosmosdb" token and the resource group id.  

`location` : Location of the CosmosDB Account, default to the location of the resource group.  

`tier` : Offering type of the CosmosDB Account, default to Standard.