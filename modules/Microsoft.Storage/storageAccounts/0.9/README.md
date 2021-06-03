# Create a Storage Account

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/storageAccounts/0.9/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/storageAccounts/0.9/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/storageAccounts/0.9/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/storageAccounts/0.9/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/storageAccounts/0.9/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/storageAccounts/0.9/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Storage%2FstorageAccounts%2F0.9%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Storage%2FstorageAccounts%2F0.9%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Storage%2FstorageAccounts%2F0.9%2Fazuredeploy.json)    

This module creates a storage account. This version does not support configuration of individual IPRules or storage services.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| storageAccountName | string | No | Specifies the name of the storageAccount, this value must be globally unique. |
| location | string | No | Specifies the Azure location where the storageAccount should be created. |
| skuName | string | No | Specifies the sku name for the storage account. |
| kind | string | No | Specifies the type of storage account.|
| accessTier | string | No | Required for storage accounts where kind = BlobStorage. The access tier used for billing. |
| minimumTlsVersion | string | No | Set the minimum TLS version to be permitted on requests to storage. |
| supportsHttpsTrafficOnly |  bool | No | Allows https traffic only to storage service if set to true. |
| allowBlobPublicAccess |  bool | No | Allow or disallow public access to all blobs or containers in the storage account. |
| allowSharedKeyAccess |  bool | No | Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). |
| networkAclsBypass |  string | No | Specifies whether traffic is bypassed by the indicated service. |
| networkAclsDefaultAction |  string | No | Specifies the default action of allow or deny when no other rules match. |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| storageAccountName | string | The name of the KeyVault. |
| location | string | The resource location of the storage account. |
| storageAccountResourceGroup | string | The name of resource group for the storage account. |

```apiVersion: 2021-01-01```
