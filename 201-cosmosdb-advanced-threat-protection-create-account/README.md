# Create an Azure CosmosDB Account with Advanced Threat Protection (preview) enabled

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-cosmosdb-advanced-threat-protection-create-account/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-cosmosdb-advanced-threat-protection-create-account/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-cosmosdb-advanced-threat-protection-create-account/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-cosmosdb-advanced-threat-protection-create-account/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-cosmosdb-advanced-threat-protection-create-account/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-cosmosdb-advanced-threat-protection-create-account/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-cosmosdb-advanced-threat-protection-create-account%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-cosmosdb-advanced-threat-protection-create-account/azuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This ARM template is intented to create a **CosmosDB Account** quickly with the **minimal required values** and **Advanced Threat Protection**.

CosmosDB Advanced Threat Protection is a unified package for advanced CosmosDB security capabilities. See the [official documentation]( https://go.microsoft.com/fwlink/?linkid=2097603) for more information.

`Tags : CosmosDB, Advanced Threat Protection`

## Parameters
The following parameters have default values allowing to deploy the template as-is without providing any parameter, but can be overriden at deployment time:

`Name` : Name of the CosmosDB Account, default is a unique string calculated from the "cosmosdb" token and the resource group id.  

`Location` : Location of the CosmosDB Account, default to the location of the resource group.  

`Tier` : Offering type of the CosmosDB Account, default to Standard.

`Advanced Threat Protection Enabled` : Advanced Threat Protection for the CosmosDB Account, default to true (enabled).

