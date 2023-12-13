---
description: This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 14.04.4-LTS or 16.04-LTS. These VMs are behind a load balancer with NAT rules for ssh connections.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-linux-nat-zones
languages:
- json
---
# Deploy a VM Scale Set with Linux VMs in Availabilty Zones

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat-zones/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat-zones/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat-zones/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat-zones/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat-zones/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-linux-nat-zones/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-nat-zones%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-nat-zones%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-linux-nat-zones%2Fazuredeploy.json)

This template allows you to deploy a simple VM Scale Set of Linux VMs within an Availability Zone using the latest patched version of Ubuntu Linux 16.04-LTS or 14.04.4-LTS. To connect from the load balancer to a VM in the scale set, you would go to the Azure Portal, find the load balancer of your scale set, examine the NAT rules, then connect using the NAT rule you want. For example, if there is a NAT rule on port 50000, you could use the following command to connect to that VM:

ssh -p 50000 {username}@{public-ip-address}

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Compute/virtualMachineScaleSets`
