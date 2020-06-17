# Create an Azure Virtual Network QuickStart

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-vnet/FairfaxDeployment.svg)
    
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-nat-gateway-vnet/CredScanResult.svg)
    
    
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-virtual-network-2vms-create%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2101-virtual-network-2vms-create%2Fazuredeploy.json)



This template deploys a **virtual network** and two virtual machines with a single subnet.

## Overview and deployed resources

This template is a resource manager implementation of a quickstart for deploying a virtual network with a single subnet. Two VMs are deployed to the virtual network ao that you securely communicate between them and connect to VMs from the internet  

For more information on **Virtual Network** service, see:

* [What is Azure Virtual Network?](https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview)


The following resources are deployed as part of the solution:

### Microsoft.Network

Description

+ **networkingSecurityGroups**: Network security group for virtual machines.
  + **securityrules**: NSG rule to open port 3389 to virtual machines.
+ **publicIPAddresses**: Public IP address for virtual machines.
+ **virtualNetworks**: Virtual network for virtual machines.
  + **subnets**: Subnet for virtual network and virtual machines.
+ **networkinterfaces**: Network interface for virtual machines.

### Microsoft.Compute

Description

+ **virtualMachines**: Virtual machine for solution

## Deployment steps
You can select Deploy to Azure at the top of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes
This template is used by the Azure Virtual Network documentation QuickStart article.

`Tags: virtual network, vnet, virtual machine`


