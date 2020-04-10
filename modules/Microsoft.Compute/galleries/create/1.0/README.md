# Create Shared Image Gallery

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.Compute/galleries/create/1.0/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.Compute/galleries/create/1.0%2Fazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.Compute/galleries/create/1.0%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

This module creates a Shared Image Gallery.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| galleryName | string | No | The name of the Shared Image Gallery. The allowed characters are alphabetic, numeric and periods. The maximum length is 80 characters. |
| description | string | No | The description of this Shared Image Gallery resource. This property is updatable. |
| location | string | No | The resource location of the gallery |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| galleryName | string | The name of the Shared Image Gallery. The allowed characters are alphabetic, numeric and periods. The maximum length is 80 characters. |
| location | string | The resource location of the gallery. |

```apiVersion: 2019-12-01```
