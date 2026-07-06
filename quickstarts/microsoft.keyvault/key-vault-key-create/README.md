---
description: This template creates an Azure Key Vault with RBAC authorization enabled and a cryptographic key.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: key-vault-key-create
languages:
- bicep
- json
---
# Create an Azure Key Vault and a key

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-key-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-key-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-key-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-key-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-key-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-key-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-key-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-key-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-key-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-key-create%2Fazuredeploy.json)

This template creates an Azure Key Vault with RBAC authorization enabled and a cryptographic key stored inside the key vault. The vault uses Azure role-based access control (Azure RBAC) for data plane authorization. To learn more about how to deploy the template, see the [quickstart](https://learn.microsoft.com/azure/key-vault/keys/quick-create-template) article.

If you're new to Azure Key Vault, see:

- [Azure Key Vault service](https://azure.microsoft.com/services/key-vault/)
- [Azure Key Vault documentation](https://learn.microsoft.com/azure/key-vault/)
- [Azure Key Vault RBAC guide](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure Key Vault template reference](https://learn.microsoft.com/azure/templates/microsoft.keyvault/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Keyvault)

If you're new to the template development, see:

- [Azure Resource Manager documentation](https://learn.microsoft.com/azure/azure-resource-manager/)

`Tags: Azure Key Vault, Key Vault, Keys, Resource Manager, Resource Manager templates, ARM templates, Microsoft.KeyVault/vaults, Microsoft.KeyVault/vaults/keys`
