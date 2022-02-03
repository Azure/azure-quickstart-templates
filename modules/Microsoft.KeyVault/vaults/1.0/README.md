# Create a Key Vault

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/1.0/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/1.0/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/1.0/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/1.0/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/1.0/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.KeyVault/vaults/1.0/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.KeyVault/vaults/1.0%2Fazuredeploy.json)
[![Deploy To Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.KeyVault/vaults/1.0%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.KeyVault/vaults/1.0%2Fazuredeploy.json)



This module creates a Key Vault.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| vaultName | string | No | Specifies the name of the KeyVault, this value must be globally unique. |
| location | string | No | Specifies the Azure location where the key vault should be created. |
| enabledForDeployment | bool | No | Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. |
| enabledForDiskEncryption | bool | No | Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.|
| enabledForTemplateDeployment | bool | No | Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault. |
| enablePurgeProtection | bool | No | Property specifying whether protection against purge is enabled for this vault. This property does not accept false but enabled here to allow for this to be optional, if false, the property will not be set. |
| enableRbacAuthorization |  bool | No | Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored. |
| enableSoftDelete |  bool | No | Property to specify whether the 'soft delete' functionality is enabled for this key vault. If it's not set to any value(true or false) when creating new key vault, it will be set to true by default. Once set to true, it cannot be reverted to false. |
| softDeleteRetentionInDays |  int | No | softDelete data retention days, only used if enableSoftDelete is true. It accepts >=7 and <=90. |
| tenantId |  string | No | Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet. |
| networkRuleBypassOptions |  string | No | Tells what traffic can bypass network rules. This can be 'AzureServices' or 'None'. If not specified the default is 'AzureServices'. |
| NetworkRuleAction | string | No | The default action when no rule from ipRules and from virtualNetworkRules match. This is only used after the bypass property has been evaluated. allowedValues [ 'Allow', 'Deny' ] |
| ipRules |  array | No | An array of IPv4 addresses or rangea in CIDR notation, e.g. '124.56.78.91' (simple IP address) or '124.56.78.0/24' (all addresses that start with 124.56.78). |
| accessPolicies |  array | No | An complex object array that contains the complete definition of the access policy.  See the [accessPolicy](https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/2019-09-01/vaults#accesspolicyentry-object) documentation for details. |
| virtualNetworkRules |  array | No | An array for resourceIds for the virtualNetworks allowed to access the vault. |
| skuName | string | No | Standard | Specifies whether the key vault is a standard vault or a premium vault.  allowedValues [ Standard, Premium ] |
| tags | object | No | Tags to be assigned to the KeyVault. |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| vaultName | string | The name of the KeyVault. |
| location | string | The resource location of the gallery. |

```apiVersion: 2019-09-01```


