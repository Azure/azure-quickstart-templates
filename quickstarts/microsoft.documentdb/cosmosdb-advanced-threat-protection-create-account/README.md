# Create an Azure CosmosDB Account with Advanced Threat Protection (preview) enabled

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-advanced-threat-protection-create-account/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-advanced-threat-protection-create-account/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-advanced-threat-protection-create-account/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-advanced-threat-protection-create-account/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-advanced-threat-protection-create-account/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.documentdb/cosmosdb-advanced-threat-protection-create-account/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-advanced-threat-protection-create-account%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-advanced-threat-protection-create-account%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.documentdb%2Fcosmosdb-advanced-threat-protection-create-account%2Fazuredeploy.json)
    

<a href="http://armviz.io/#/?load=azuredeploy.json" target="_blank">

This ARM template is intended to create a **CosmosDB Account** quickly with the **minimal required values** and **Advanced Threat Protection**.

CosmosDB Advanced Threat Protection is a unified package for advanced CosmosDB security capabilities. See the [official documentation]( https://go.microsoft.com/fwlink/?linkid=2097603) for more information.

`Tags : CosmosDB, Advanced Threat Protection`

## Parameters
The following parameters have default values allowing to deploy the template as-is without providing any parameter, but can be overriden at deployment time:

`Name` : Name of the CosmosDB Account, default is a unique string calculated from the "cosmosdb" token and the resource group id.  

`Location` : Location of the CosmosDB Account, default to the location of the resource group.  

`Tier` : Offering type of the CosmosDB Account, default to Standard.

`Advanced Threat Protection Enabled` : Advanced Threat Protection for the CosmosDB Account, default to true (enabled).


