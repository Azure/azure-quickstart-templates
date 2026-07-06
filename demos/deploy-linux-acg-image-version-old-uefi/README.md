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

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/deploy-linux-acg-image-version-old-uefi/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdeploy-linux-acg-image-version-old-uefi%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdeploy-linux-acg-image-version-old-uefi%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdeploy-linux-acg-image-version-old-uefi%2Fazuredeploy.json)

This template creates an Azure Compute Gallery with an image definition and image version from a linux marketplace image. The image version includes a custom UEFI security profile with PK, KEK, and db signatures to support Trusted Launch and Confidential VM scenarios with old UEFI certificate configurations. For more information about custom UEFI keys, see [Secure Boot UEFI keys](https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch-secure-boot-custom-uefi).


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

## Creating a Trusted Launch VM from the Gallery Image Version

After the template deploys successfully, the output `galleryImageVersionId` contains the resource ID of the gallery image version. Use any of the following methods to create a Trusted Launch VM from it.

### Azure Portal

1. Navigate to the **Azure Compute Gallery** resource created by the deployment.
2. Select the **Image Definition** and then the **Image Version** (`1.0.0`).
3. Click **Create VM**.
4. Under the **Security type** dropdown, select **Trusted launch virtual machines**.
5. Ensure **Secure Boot** and **vTPM** are enabled.
6. Configure the remaining VM settings (size, networking, disks, etc.) and click **Review + create**.

### Azure CLI

```bash
az vm create \
  --resource-group <resource-group> \
  --name <vm-name> \
  --image <galleryImageVersionId> \
  --security-type TrustedLaunch \
  --enable-secure-boot true \
  --enable-vtpm true \
  --admin-username azureuser \
  --generate-ssh-keys
```

Replace `<galleryImageVersionId>` with the `galleryImageVersionId` value from the deployment outputs.

### Azure PowerShell

```powershell
$imageId = "<galleryImageVersionId>"

New-AzVM `
  -ResourceGroupName "<resource-group>" `
  -Name "<vm-name>" `
  -Location "<location>" `
  -ImageName $imageId `
  -SecurityType "TrustedLaunch" `
  -EnableSecureBoot $true `
  -EnableVtpm $true `
  -GenerateSshKey
```

Replace `<galleryImageVersionId>` with the `galleryImageVersionId` value from the deployment outputs.

For more information about using Azure Compute Gallery image version to create VM, see [Create a VM from a gallery image version](https://learn.microsoft.com/en-us/azure/virtual-machines/vm-generalized-image-version?tabs=cli%2Ccli2%2Ccli3%2Ccli4)

`Tags: Microsoft.Compute/disks, Microsoft.Compute/images, Microsoft.Compute/galleries, Microsoft.Compute/galleries/images, Microsoft.Compute/galleries/images/versions`
