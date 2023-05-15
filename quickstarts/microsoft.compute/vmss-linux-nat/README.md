---
description: This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 14.04.4-LTS or 16.04-LTS. These VMs are behind a load balancer with NAT rules for ssh connections.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-linux-nat
languages:
- json
---
# Deploy a simple VM Scale Set with Linux VMs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-nat%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-nat%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-nat%2Fazuredeploy.json)

This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 16.04-LTS or 14.04.4-LTS. To connect from the load balancer to a VM in the scale set, you would go to the Azure Portal, find the load balancer of your scale set, examine the NAT rules, then connect using the NAT rule you want. For example, if there is a NAT rule on port 50000, you could use the following command to connect to that VM:

ssh -p 50000 {username}@{public-ip-address}

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Compute/virtualMachineScaleSets`
