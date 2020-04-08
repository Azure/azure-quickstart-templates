# Virtual Network NAT

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-1-vm/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-1-vm/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-1-vm/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-1-vm/FairfaxDeployment.svg" />&nbsp;
    
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-1-vm/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-1-vm/CredScanResult.svg" />&nbsp;
    
    
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-nat-gateway-1-vm%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-nat-gateway-1-vm%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

This template deploys a **NAT gateway** and supporting resources.

## Overview and Deployed resources

This template is a resource manager implementation of a quickstart for deploying a NAT gateway.  A Ubuntu virtual machine is deployed to the subnet that is associated with the NAT gateway.

For more information on **Virtual Network NAT** service and **NAT gateway** see:

* [What is Virtual Network NAT?](https://docs.microsoft.com/azure/virtual-network/nat-overview)

* [Designing virtual networks with NAT gateway resources](https://docs.microsoft.com/azure/virtual-network/nat-gateway-resource)

The following resources are deployed as part of the solution

### Microsoft.Network

Description

+ **networkingSecurityGroups**: Network security group for virtual machine.
  + **securityrules**: NSG rule to open port 22 to virtual machine.
+ **publicIPAddresses**: Public IP address for NAT gateway and virtual machine.
+ **publicIPPrefixes**: Public IP prefix for NAT gateway.
+ **natGateways**: NAT gateway resource
+ **virtualNetworks**: Virtual network for NAT gateway and virtual machine.
  + **subnets**: Subnet for virtual network for NAT gateway and virtual machine.
+ **networkinterfaces**: Network interface for virtual machine

### Microsoft.Compute

Description

+ **virtualMachines**: Virtual machine for solution

`Tags: virtual network, vnet, nat, nat gateway, virtual machine`
