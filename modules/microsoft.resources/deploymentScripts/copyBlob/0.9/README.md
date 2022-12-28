---
description: This module downloads a file from a uri and copies it to an Azure storageAccount blob container.  The storageAccount must already exist and the source file must already be staged to the uri.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: modules-microsoft.resources-deploymentScripts-copyBlob-0.9
languages:
- json
- bicep
---
# Copy a file from a uri to a blob storage container

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.resources/deploymentScripts/copyBlob/0.9/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.resources/deploymentScripts/copyBlob/0.9/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.resources/deploymentScripts/copyBlob/0.9/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.resources/deploymentScripts/copyBlob/0.9/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.resources/deploymentScripts/copyBlob/0.9/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.resources/deploymentScripts/copyBlob/0.9/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.resources/deploymentScripts/copyBlob/0.9/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmicrosoft.resources%2FdeploymentScripts%2FcopyBlob%2F0.9%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmicrosoft.resources%2FdeploymentScripts%2FcopyBlob%2F0.9%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmicrosoft.resources%2FdeploymentScripts%2FcopyBlob%2F0.9%2Fazuredeploy.json)

This module will copy a file from a provided uri into a blob storage container.  The storageAccount must already exist and the file staged to the uri.

Note the module must have a target scope of the resourceGroup where the existing storageAccount is located.

The principal used to deploy the module must have permissions to get the storageAccount keys or a storageAccount key must be provided.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| location | string | No | Location of the deploymentScript resource ( default = `resourceGroup().location` ) |
| storageAccountName | string | Yes | Name of the existing storageAccount to copy the file to. |
| containerName | string | Yes | Container for the blob. Currently the container will be created so the principal deploying the module must have permission to create the container. |
| contentUri | string | Yes | Uri to the source file including sasToken if necessary. |
| storageAccountKey | string | No | storageAccountKey used for permission to copy the blob, if not provided, the module will attempt to retrieve the key. |

`Tags: `
