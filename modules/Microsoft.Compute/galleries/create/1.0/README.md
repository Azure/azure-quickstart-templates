---
description: This module creates an Azure Compute Gallery resource with apiVersion 2019-12-01.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: modules-Microsoft.Compute-galleries-create-1.0
languages:
- json
---
# Create an Azure Compute Gallery

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Compute%2Fgalleries%2Fcreate%2F1.0%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Compute%2Fgalleries%2Fcreate%2F1.0%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.Compute%2Fgalleries%2Fcreate%2F1.0%2Fazuredeploy.json)   

This module creates an Azure Compute Gallery.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| galleryName | string | No | The name of the gallery. The allowed characters are alphabetic, numeric and periods. The maximum length is 80 characters. |
| description | string | No | The description of this gallery resource. This property is updatable. |
| location | string | No | The resource location of the gallery |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| galleryName | string | The name of the gallery. The allowed characters are alphabetic, numeric and periods. The maximum length is 80 characters. |
| location | string | The resource location of the gallery. |

```apiVersion: 2019-12-01```

`Tags: Microsoft.Compute/galleries`
