---
description: This template allows you to create Virtual Machines distributed across Availability Zones with a Load Balancer and configure NAT rules through the load balancer. This template also deploys a Virtual Network, Public IP address and Network Interfaces. In this template, we use the resource loops capability to create the network interfaces and virtual machines
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: multi-vm-lb-zones
languages:
- json
---
# VMs in Availability Zones with a Load Balancer and NAT

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/multi-vm-lb-zones/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/multi-vm-lb-zones/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/multi-vm-lb-zones/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/multi-vm-lb-zones/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/multi-vm-lb-zones/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/multi-vm-lb-zones/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fmulti-vm-lb-zones%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fmulti-vm-lb-zones%2Fazuredeploy.json)

This template allows you to create 1 to 10 Virtual Machines in Availability Zones and configure NAT rules through the standard load balancer. This template also deploys a virtual network, public IP address and network interfaces.

In this template, we use the resource loops capability to create the network interfaces and virtual machines.

The virtual machines are spread out into different availability zones.

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Network/loadBalancers, Microsoft.Network/loadBalancers/inboundNatRules, Microsoft.Compute/virtualMachines`
