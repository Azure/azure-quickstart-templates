# Azure Image Builder with Azure Windows Baseline

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/imagebuilder-windowsbaseline/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/imagebuilder-windowsbaseline/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/imagebuilder-windowsbaseline/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/imagebuilder-windowsbaseline/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/imagebuilder-windowsbaseline/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/imagebuilder-windowsbaseline/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/demos/imagebuilder-windowsbaseline/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fimagebuilder-windowsbaseline%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fimagebuilder-windowsbaseline%2Fazuredeploy.json)

This template creates an Azure Image Builder environment and builds a Windows Server image with the latest Windows Updates and Azure Windows Baseline applied using the guest configuration feature of Azure Policy.

After the deployment completes, the build will still be running in Azure Image Gallery. To view the status, either open the
image definition in Azure portal or use a client such as PowerShell.

```powershell
Get-AzGalleryImageVersion -ResourceGroupName '<myResourceGroup>' -GalleryName '<myGalleryName>' -GalleryImageDefinitionName 'Win2019_BaselineDefinition'
```

The object returned will have details about the current build. After the build finishes, the same command
will provide details about which regions contain a replica of the build.

To deploy a custom virtual machine using the new image, after the build finishes, use the "Create VM" button
on the image definition page of the Azure portal, or a client such as PowerShell.

```PowerShell
$i = Get-AzGalleryImageDefinition -ResourceGroupName '<myResourceGroup>' -GalleryName '<myGalleryName>' -Name 'Win2019_BaselineDefinition'

# This command will prompt for username/password to use in the machine for a local admin account
New-AzVM -name '<myVMName>' -Image $i.id
```

## Resources

The following resources are created by this template:

- 1 user-assigned managed identity for running a deployment script
- 1 role definition and 1 role assignment to limit access of the new identity
- 1 Azure Image Gallery with 1 image and 1 template
- 1 deployment script to trigger the build of the custom image in Azure Image Builder
