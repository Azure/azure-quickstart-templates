---
description: This template will create N number of VM's with managed disks, public IPs and network interfaces. It will create the VMs in a Virtual Machine Scale Set in Flexible Orchestration mode. They will be provisioned in a Virtual Network which will also be created as part of the deployment 
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-flexible-orchestration-manual-add-vm
languages:
- json
---
# Add multiple VMs into a Virtual Machine Scale Set

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-manual-add-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-manual-add-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-manual-add-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-manual-add-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-manual-add-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-flexible-orchestration-manual-add-vm/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-flexible-orchestration-manual-add-vm%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-flexible-orchestration-manual-add-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-flexible-orchestration-manual-add-vm%2Fazuredeploy.json)

This template will provision N number of virtual machines with your choice in a single VNET. Every VM will be provisioned with a Network Interface and a Public IP resource. All the VMs will be provisioned in a Virtual Machine Scale Set in Flexible Orchestration Mode.
If you provision 3 VM’s with this template, your resources will look similar to this in the resource group.

![template resources](images/resources.png "template resource objects")

`Tags: Managed Disks, Azure VMs, VMSS, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Compute/virtualMachineScaleSets, Microsoft.Compute/virtualMachines, Microsoft.Network/networkInterfaces, Microsoft.Network/publicIPAddresses`

