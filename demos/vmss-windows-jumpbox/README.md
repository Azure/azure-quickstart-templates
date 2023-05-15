---
description: This template allows you to deploy a simple VM Scale Set of Windows VMs using the lastest patched version of serveral Windows versions. This template also deploys a jumpbox with a public IP address in the same virtual network. You can connect to the jumpbox via this public IP address, then connect from there to VMs in the scale set via private IP addresses.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-windows-jumpbox
languages:
- json
---
# Deploy a simple VM Scale Set with Windows VMs and a Jumpbox

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-windows-jumpbox/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-windows-jumpbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-windows-jumpbox/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-windows-jumpbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-windows-jumpbox/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-windows-jumpbox/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-windows-jumpbox%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-windows-jumpbox%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-windows-jumpbox%2Fazuredeploy.json)

This template allows you to deploy a simple VM Scale Set of Windows VMs using the latest patched version of serveral Windows versions. This template also deploys a jumpbox with a public IP address in the same virtual network. You can connect to the jumpbox via this public IP address, then connect from there to VMs in the scale set via private IP addresses.

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachineScaleSets`
