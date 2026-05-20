---
description: This template creates an Azure Compute Gallery with an image definition and image version from a linux marketplace image. The image version includes a custom UEFI security profile with PK, KEK, and db signatures to support Trusted Launch and Confidential VM scenarios with old UEFI certificate configurations.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: deploy-linux-acg-image-version-old-uefi
languages:
- json
---
# Azure Compute Gallery image version from Linux image and UEFI keys

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/PublicDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdeploy-linux-acg-image-version-old-uefi%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdeploy-linux-acg-image-version-old-uefi%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdeploy-linux-acg-image-version-old-uefi%2Fazuredeploy.json)

This template creates an Azure Compute Gallery with an image definition and image version from a linux marketplace image. The image version includes a custom UEFI security profile with PK, KEK, and db signatures to support Trusted Launch and Confidential VM scenarios with old UEFI certificate configurations.

## Resources

The template deploys the following resources:

- **Managed Disk** - Created from a marketplace image reference
- **Managed Image** - Created from the managed disk as a generalized Gen2 image
- **Azure Compute Gallery** - Hosts the image definition and versions
- **Gallery Image Definition** - Defines the image with TrustedLaunch and Confidential VM support
- **Gallery Image Version** - Published with shallow replication and custom UEFI signatures

## Prerequisites

- The specified marketplace image must be available in the target region
- The image must support Trusted Launch

`Tags: Microsoft.Compute/disks, Microsoft.Compute/images, Microsoft.Compute/galleries, Microsoft.Compute/galleries/images, Microsoft.Compute/galleries/images/versions`
