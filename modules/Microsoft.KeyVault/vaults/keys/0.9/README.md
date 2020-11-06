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

For more details about the key parameters see the [API reference documentation](https://docs.microsoft.com/en-us/rest/api/keyvault/CreateKey/CreateKey).

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| vaultName | string | Yes | Specifies the name of the KeyVault, this vault must already exist. |
| keyName | string | Yes | Specifies the name of the key to be created. |
| attributes | string | No | The attributes of a key managed by the key vault service. |
| crv | string | No | Elliptic curve name. |
| key_ops | string | No | JSON web key operations. Operations include: 'encrypt', 'decrypt', 'sign', 'verify', 'wrapKey', 'unwrapKey' |
| key_size | string | No | The key size in bits. For example: 2048, 3072, or 4096 for RSA. |
| kty | string | No | The type of key to create. |
| tags | object | No | Tags to be assigned to the KeyVault. |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| key | object | The properties of the created key. |

```apiVersion: 2019-09-01```
