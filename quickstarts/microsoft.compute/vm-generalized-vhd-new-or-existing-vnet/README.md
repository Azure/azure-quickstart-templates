---
description: This template creates a VM from a generalized VHD and let you connect it to a new or existing VNET that can reside in another Resource Group than the virtual machine
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-generalized-vhd-new-or-existing-vnet
languages:
- json
---
# Create a VM in a new or existing vnet from a generalized VHD

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-generalized-vhd-new-or-existing-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-generalized-vhd-new-or-existing-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-generalized-vhd-new-or-existing-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-generalized-vhd-new-or-existing-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-generalized-vhd-new-or-existing-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-generalized-vhd-new-or-existing-vnet/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-generalized-vhd-new-or-existing-vnet%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-generalized-vhd-new-or-existing-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-generalized-vhd-new-or-existing-vnet%2Fazuredeploy.json)

## Prerequisites

- A generalized VHD file that you want to create a VM from already exists in a storage account.
- Name of the resource group, existing VNET and subnet you want to connect the new virtual machine to if you're using an existing vnet

This template creates a VM from a generalized VHD and lets you connect it to a new or existing VNET that can reside in another Resource Group then the virtual machine.

Plese note: This deployment template does not create or attach an existing Network Security Group to the virtual machine.

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/images, Microsoft.Compute/virtualMachines`
