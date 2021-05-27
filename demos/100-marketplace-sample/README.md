# Azure Marketplace VM with CreateUIDefinition

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/100-marketplace-sample/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/100-marketplace-sample/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/100-marketplace-sample/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/100-marketplace-sample/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/100-marketplace-sample/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/100-marketplace-sample/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F100-marketplace-sample%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F100-marketplace-sample%2FcreateUiDefinition.json)
[![Deploy To Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F100-marketplace-sample%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F100-marketplace-sample%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F100-marketplace-sample%2Fazuredeploy.json)

This template allows deploying a linux VM using new or existing resources for the Virtual Network, Storage and Public IP Address.  It also allows for choosing between SSH and Password authentication.  The templates uses conditions and logic functions to remove the need for nested deployments.

This template contains extra parameters to allow for the existing resources use cases, which is a common scenario for Azure Applications in the Azure Marketplace.

createUiDefinition.json is also included.

Before submitting to Marketplace, the following steps will need to be performed

- Rename ```azuredeploy.json``` to ```mainTemplate.json```
- Remove ```azuredeploy.parameters.json``` from the list of files to be submitted
- Update the GUID in ```mainTemplate.json``` for Customer Usage Attribution
  - https://docs.microsoft.com/en-us/azure/marketplace/marketplace-solution-templates
- Create a zip package of all the dependencies including the templates files, scripts, UI definition etc
  - https://docs.microsoft.com/en-us/azure/marketplace/cloud-partner-portal/azure-applications/cpp-skus-tab#package-details-for-solution-template 
  
  `Tags: new, exiting, resource, vm, condition, conditional`
