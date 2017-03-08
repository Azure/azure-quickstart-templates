# Simple deployment of Managed VMs using Marketplace Gallery image and Managed Disks

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-with-managed-osdisk-datadisk/azuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-with-managed-osdisk-datadisk/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy multiple simple managed Windows VMs with mulitple managed data disks to an existing VNet and Subnet in the same resource group.  

To deploy this template using the scripts from the root of this repo: (change the folder name below to match the folder name for this sample)

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '[foldername]'
```
```bash
azure-group-deploy.sh -a [foldername] -l eastus -u
```
If your sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script (think of this as "temp" storage for AzureRM) and reused by subsequent deployments.

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '101-vm-with-managed-osdisk-datadisk' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a 101-vm-with-managed-osdisk-datadisk -l eastus -u
```

`Tags: vm, disks, managed, manageddisks, managedvm, nested, linkedtemplate, nic, nsg, pip`

## Solution overview and deployed resources

By default this solution deploys a single managed VM (Standard_A1_v2 - 128GB) with two (2) managed data disks using (128GB - Standard_LRS).  To enable access to the VM a NIC, NSG and Public IP Adress
are also created.  The parameters can be modified to create multiple VMs with multiple managed data disks of the same size, storage type, disk size, and Marketplace Image.  The allowed port for remote access in the NSG rule
can be set by providing the vmOSVersion [Windows | Linux], this should reflect the image that's used to create the VM(s).   

The following resources are deployed as part of the solution

#### Microsoft.Compute

Azure Resource Manager Computer Provider

+ **virtualMachines**: Resource type used to create VMs using a copy loop.
+ **disks**: Resource type used to create managed disks using a copy loop.

#### Microsoft.Network

Azure Resource Manager Network Provider

+ **networkSecurityGroups**: Resource type used to create an NSG for remote access and associated to a VMs NIC using a copy loop.
+ **networkInterfaces**: Resource type used to create a NIC for each VM using a copy loop.
+ **publicIPAddresses**: Resource type used to create a Public IP for each VM to enable remote access using a copy loop.

#### Microsoft.Resources

Azure Resource Manager Resources Provider

+ **deployments**: Resource type used to link managed-datadisks-template.json and created managed disks.


## Prerequisites

A resource group with an existing VNet and subnet are required.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

You can use your own custom Managed Image resource by navigating to the virtualMachines resource > properties > storageProfile > imagaReference and deleting the publisher, offer, sku, and version keys and values completely and replacing them with 
"id": "[reosurceId('Microsoft.Compute/images','Your Image Name Goes Here')]"
