---
description: Deploy a NAT gateway and virtual machine
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: nat-gateway-1-vm
languages:
- json
- bicep
---
# Virtual Network NAT with VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-1-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-1-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-1-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-1-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-1-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-1-vm/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-1-vm/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnat-gateway-1-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnat-gateway-1-vm%2Fazuredeploy.json)

This template deploys a **NAT gateway** and supporting resources.

## Overview

This template is a resource manager implementation of a quickstart for deploying a NAT gateway. An Ubuntu virtual machine is deployed to the subnet that is associated with the NAT gateway. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/virtual-network/quickstart-create-nat-gateway-template) article.

For more information on **Virtual Network NAT** service and **NAT gateway** see:

- [What is Virtual Network NAT?](https://docs.microsoft.com/azure/virtual-network/nat-overview)
- [Designing virtual networks with NAT gateway resources](https://docs.microsoft.com/azure/virtual-network/nat-gateway-resource)

## Deployed resources

The following resources are deployed as part of the solution.

### Microsoft.Network

- **networkingSecurityGroups**: Network security group for virtual machine.
  - **securityrules**: NSG rule to open port 22 to virtual machine.
- **publicIPAddresses**: Public IP address for NAT gateway and virtual machine.
- **publicIPPrefixes**: Public IP prefix for NAT gateway.
- **natGateways**: NAT gateway resource.
- **virtualNetworks**: Virtual network for NAT gateway and virtual machine.
  - **subnets**: Subnet for virtual network for NAT gateway and virtual machine.
- **networkinterfaces**: Network interface for virtual machine.

### Microsoft.Compute

- **virtualMachines**: Virtual machine for solution.

`Tags: virtual network, vnet, nat, nat gateway, virtual machine, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/publicIPPrefixes, Microsoft.Compute/virtualMachines, Microsoft.Network/virtualNetworks, Microsoft.Network/natGateways, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/networkInterfaces`
