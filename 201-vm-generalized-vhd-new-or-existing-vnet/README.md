# Create a virtual machine from a generalized vhd in a new or existing virtual network

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-generalized-vhd-new-or-existing-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-generalized-vhd-new-or-existing-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-generalized-vhd-new-or-existing-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-generalized-vhd-new-or-existing-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-generalized-vhd-new-or-existing-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-generalized-vhd-new-or-existing-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-generalized-vhd-new-or-existing-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-generalized-vhd-new-or-existing-vnet%2Fazuredeploy.json)

## Prerequisites

- A generalized VHD file that you want to create a VM from already exists in a storage account.
- Name of the resource group, existing VNET and subnet you want to connect the new virtual machine to if you're using an existing vnet

This template creates a VM from a generalized VHD and lets you connect it to a new or existing VNET that can reside in another Resource Group then the virtual machine.

Plese note: This deployment template does not create or attach an existing Network Security Group to the virtual machine. 


