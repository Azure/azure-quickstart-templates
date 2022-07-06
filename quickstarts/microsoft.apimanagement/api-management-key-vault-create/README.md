---
description: This template deploys an API Management service configured with User Assigned Identity. It uses this identity to fetch SSL certificate from KeyVault and keeps it updated by checking every 4 hours.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: api-management-key-vault-create
languages:
- json
- bicep
---
# Create an API Management service with SSL from KeyVault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-key-vault-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-key-vault-create%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-key-vault-create%2Fazuredeploy.json)

The Template deploys API Management service Standard Tier with integration with Managed Identities. Please refer to documentation at aka.ms/apimmsi.

The template shows how to create an API Management with SSL retrieved from Key Vault using a single click deployment using User Assigned identities.

With System Assigned identity, associating an API Management with SSL was a two step process. With User Assigned identities, this is single step.

It deploys the following components
- User Assigned Managed Identity
- Key Vault which is granted access to the Managed Identity
- API Management service which is assigned access to the Key Vault using User Assigned Identity.
- The API Management protocols and ciphers are configured to enhance security

If you're new to Azure API Management, see:

- [Azure API Management service](https://azure.microsoft.com/services/api-management/)
- [Azure API Management documentation](https://docs.microsoft.com/azure/api-management/)
- [Azure API Management Configure custom domain](https://docs.microsoft.com/azure/api-management/configure-custom-domain)
- [Azure API Management Configure protocols and ciphers](https://docs.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
- [Azure Key Vault template reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Apimanagement)

If you're new to Azure Key Vault, see:

- [Azure Key Vault service](https://azure.microsoft.com/services/key-vault/)
- [Azure Key Vault documentation](https://docs.microsoft.com/azure/key-vault/)
- [Azure Key Vault RBAC permission model](https://docs.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure Key Vault template reference](https://docs.microsoft.com/azure/templates/microsoft.keyvault/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Keyvault)

If you're new to the template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: API, API Management, Azure API Management, Azure Key Vault, Key Vault, Secret, Certificate, Managed Identity, Microsoft.ManagedIdentity/userAssignedIdentities, Microsoft.KeyVault/vaults, Microsoft.KeyVault/vaults/secrets, Microsoft.Authorization/roleAssignments, Microsoft.ApiManagement/service, UserAssigned, Proxy`