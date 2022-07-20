---
description: This template deploys and Azure Maps account and lists a Sas token based on the provided User Assigned identity to be stored in an Azure Key Vault secret.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: maps-use-sas
languages:
- json
---
# Create Azure Maps SAS token stored in an Azure Key Vault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.maps/maps-use-sas/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.maps/maps-use-sas/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.maps/maps-use-sas/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.maps/maps-use-sas/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.maps/maps-use-sas/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.maps/maps-use-sas/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.maps%2Fmaps-use-sas%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.maps%2Fmaps-use-sas%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.maps%2Fmaps-use-sas%2Fazuredeploy.json)

This template creates an Azure Maps account with configured Cross Origin Resource Sharing (CORS) and will list a SAS token to be stored as a secret in an Azure Key Vault. Deployment of this template will create new SAS token every time. Re-deployment of a past deployment should be aware of the effective behavior on start and duration parameters which are based on [DateTime functions](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-functions-date). To learn more about how to deploy the template, see the [article](https://docs.microsoft.com/azure/azure-maps/how-to-create-template) article.

If you're new to Azure Maps, see:

- [Azure Maps service](https://azure.microsoft.com/services/azure-maps/)
- [Azure Maps documentation](https://docs.microsoft.com/azure/azure-maps/)
- [Azure Maps template reference](https://docs.microsoft.com/azure/templates/microsoft.maps/accounts)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Maps)

If you're new to Azure Resource Manager template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Microsoft.Maps/accounts, UserAssigned, Microsoft.Maps/accounts/providers/roleAssignments, Microsoft.KeyVault/vaults/secrets, Microsoft.ManagedIdentity/userAssignedIdentities, Microsoft.KeyVault/vaults`
