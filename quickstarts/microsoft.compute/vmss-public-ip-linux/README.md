---
description: This template demonstrates deploying a simple scale set with load balancer, inbound NAT rules, and public IP per VM.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-public-ip-linux
languages:
- json
---
# Simple VM Scale Set with Linux VMs and public IPv4 per VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-public-ip-linux/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-public-ip-linux/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-public-ip-linux/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-public-ip-linux/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-public-ip-linux/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-public-ip-linux/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-public-ip-linux%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-public-ip-linux%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-public-ip-linux%2Fazuredeploy.json)

This template deploys a simple VM Scale Set of Ubuntu 16.04-LTS VMs and assigns a public IP address to each one. With this scale set you can connect directly to the public IP addresses, or indirectly to the scale set VM private IP addresses using the load balancer inbound NAT rules:

Direct connection: ssh {username}@{public-ip-address of VM}

Indirect connection via load balancer: ssh -p 50000 {username}@{load balancerpublic-ip-address}

To determine the public IP address of each VM using Azure CLI 2.0 (July 2017 version or later), using the _az vmss list-instance-public-ips_ command. See [Networking for Azure virtual machine scale sets](https://docs.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-networking) for more details on Azure scale set networking features.

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure.

instanceCount must be 100 or less (you could adapt this template to deploy up to 1000 VMs, if you removed the load balancer and changed the singlePlacementGroup property to _false_. If you need a scale set of more than 100 VMs with load balancer, use the Application Gateway instead).

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Compute/virtualMachineScaleSets`
