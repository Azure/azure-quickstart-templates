# Create a EfficientIP virtual machine in an existing virtual network attach to a Network Security Group

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-efficientip-vhd/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-efficientip-vhd/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-efficientip-vhd/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-efficientip-vhd/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-efficientip-vhd/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-efficientip-vhd/CredScanResult.svg)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-efficientip-vhd-existing-vnet%2Fazuredeploy.json" target="_blank">
    

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-efficientip-vhd-existing-vnet%2Fazuredeploy.json" target="_blank">
    


## Prerequisites

- EfficientIP VHD file that you want to create a VM from already exists in a storage account.
- Name of the existing VNET and subnet you want to connect the new virtual machine to.
- Name of the Resource Group that the VNET resides in.
- Name of the Network Security Group that should be attach to the virtual NIC.

```
NOTE

This template will create an additional Standard_GRS storage account for enabling boot diagnostics each time you execute this template. To avoid running into storage account limits, it's best to delete the storage account when the VM is deleted.
```

This template creates a VM from a EfficientIP VHD and let you connect it to an existing VNET that can reside in another Resource Group then the virtual machine.



