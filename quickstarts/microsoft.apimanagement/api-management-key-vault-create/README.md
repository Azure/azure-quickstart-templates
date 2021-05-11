# Create API Management service with Key Vault based SSL

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-key-vault-create%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-key-vault-create%2Fazuredeploy.json)

The Template deploys API Management service Standard Tier with integration with Managed Identities. Please refer to documentation at aka.ms/apimmsi.

The template shows how to create an API Management with SSL retrieved from Key Vault using a single click deployment using User Assigned identities.

With System Assigned identity, associating an API Management with SSL was a two step process. With User Assigned identities, this is single step.

It deploys the following components
- User Assigned Managed Identity
- Key Vault which is granted access to the Managed Identity
- API Management service which is assigned access to the Key Vault using User Assigned Identity.
