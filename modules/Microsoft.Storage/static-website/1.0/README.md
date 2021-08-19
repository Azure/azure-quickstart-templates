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

This module creates a storage account, enables the static website feature, and adds index and 404 error pages.

## Parameters

| Name                     | Type   | Required | Description                                                                                                                                                                   |
|--------------------------|--------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| location                 | string | No       | The location into which the Azure Storage resources should be deployed. If not specified, defaults to the resource group's location.                                          |
| accountName              | string | No       | The name of the Azure Storage account to create. This must be globally unique. If not specified, a unique name is generated.                                                  |
| skuName                  | string | No       | The name of the SKU to use when creating the Azure Storage account. If not specified, defaults to `Standard_LRS`.                                                             |
| indexDocumentPath        | string | No       | The name of the page to display when a user navigates to the root of your static website. If not specified, defaults to `index.htm`.                                          |
| indexDocumentContents    | string | No       | The contents of the page to display when a user navigates to the root of your static website. If not specified, defaults to a simple welcome page.                            |
| errorDocument404Path     | string | No       | The name of the page to display when a user attempts to navigate to a page that does not exist in your static website. If not specified, defaults to `404.htm`.               |
| errorDocument404Contents | string | No       | The contents of the page to display when a user attempts to navigate to a page that does not exist in your static website. If not specified, defaults to a simple error page. |
| supportsHttpsTrafficOnly | bool   | No       | Indicates whether the storage account should require HTTPS traffic. If not specified, defaults to `true`.                                                                     |

## Outputs

| Name                  | Type   | Description                                                                                                                                                                                      |
|-----------------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| accountResourceId     | string | The resource ID of the storage account. For example, `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyResourceGroup/providers/Microsoft.Storage/storageAccounts/stor12345`. |
| staticWebsiteHostName | string | The host name of the static website. For example, `storaabbccdd12345.z8web.core.windows.net`.                                                                                                    |
| staticWebsiteUrl      | string | The URL to the static website. For example, `https://storaabbccdd12345.z8web.core.windows.net`.                                                                                                  |

```apiVersion: 2021-04-01```
