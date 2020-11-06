# Create a Key in an Existing Key Vault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/keys/0.9/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/keys/0.9/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/keys/0.9/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/keys/0.9/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/keys/0.9/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/keys/0.9/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.KeyVault%2Fvaults%2Fkeys%2F0.9%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.KeyVault%2Fvaults%2Fkeys%2F0.9%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.KeyVault%2Fvaults%2Fkeys%2F0.9%2Fazuredeploy.json)

This module creates a Key in a Key Vault.  The Key Vault must already exist and is not created.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| vaultName | string | No | Specifies the name of the KeyVault, this value must be globally unique. |
| virtualNetworkRules |  array | No | An array for resourceIds for the virtualNetworks allowed to access the vault. |
| skuName | string | No | Standard | Specifies whether the key vault is a standard vault or a premium vault.  allowedValues [ Standard, Premium ] |
| tags | object | No | Tags to be assigned to the KeyVault. |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| vaultName | string | The name of the KeyVault. |

```apiVersion: 2019-09-01```
