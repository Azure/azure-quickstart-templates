# Create a storage account and static website

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/static-website/1.0/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/static-website/1.0/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/static-website/1.0/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/static-website/1.0/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/static-website/1.0/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/static-website/1.0/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Storage/static-website/1.0/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Storage%2Fstatic-website%2F1.0%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Storage%2Fstatic-website%2F1.0%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Storage%2Fstatic-website%2F1.0%2Fazuredeploy.json)   

This module creates a storage account and enables the static website feature.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| location | string | No | Specifies the Azure location where the storageAccount should be created. |
| accountName | string | No | Specifies the name of the storage account. This value must be globally unique. |
| skuName | string | No | Specifies the SKU name for the storage account. |
| indexDocument | string | No | Specifies the name of the index page for the static website. |
| errorDocument404Path | string | No | Specifies the name of the error (404 error) page for the static website. |
| supportsHttpsTrafficOnly |  bool | No | Allows https traffic only to storage service if set to true. |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| accountResourceId | string | The resource ID of the storage account. |
| staticWebsiteHostName | string | The hostname of the static website. |

```apiVersion: 2021-04-01```
