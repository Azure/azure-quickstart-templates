# Create a new VM on a new storage account from a custom image

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-custom-image-new-storage-account/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-custom-image-new-storage-account/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-custom-image-new-storage-account/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-custom-image-new-storage-account/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-custom-image-new-storage-account/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-custom-image-new-storage-account/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-custom-image-new-storage-account%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-custom-image-new-storage-account%2Fazuredeploy.json)

## Note: Consider using managed disks as an alternative solution
See the [documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/migrate-to-managed-disks) for managed disks

This template allows you to create a new Virtual Machine from a custom image on a new storage account deployed together with the storage account, which means the source image VHD must be transfered to the newly created storage account before that Virtual Machine is deployed. This is accomplished by the usage of a transfer virtual machine that is deployed and then uses a script via custom script extension to copy the source VHD to the destination storage account. This process is used to overcome the limitation of the custom VHD that needs to reside at the same storage account where new virtual machines based on it will be spinned up, the problem arises when you are also deploying the storage account within your template, since the storage account does not exist yet, how can you add the source VHDs beforehand?

Basically it creates two VMs, one that is the transfer virtual machine and the second that is the actual virtual machine that is the goal of the deployment. Transfer VM can be removed later.

The process of this template is:

1. A Virtual Network is deployed
2. Virtual NICs for both Virtual Machines
3. Storage Account is created
3. Transfer Virtual Machine gets deployed
4. Transfer Virtual Machine starts the custom script extension to start the VHD copy from source to destination storage acounts
5. The new Virtual Machine based on a custom image VHD gets deployed 

## Requirements

* A preexisting generalized (sysprepped) Windows image. For more information on how to create custom Windows images, please refer to [How to capture a Windows virtual machine in the Resource Manager deployment model](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-capture-image/) article.



