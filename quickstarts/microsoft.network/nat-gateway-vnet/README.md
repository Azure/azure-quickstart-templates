# Virtual Network NAT

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-vnet/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-vnet/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnat-gateway-vnet%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnat-gateway-vnet%2Fazuredeploy.json)

This template deploys a **NAT gateway** and virtual network with a single subnet and public IP resource for the NAT gateway.

## Overview and deployed resources

This template is a resource manager implementation of a quickstart for deploying a NAT gateway.  A virtual network is deployed with a single subnet. The NAT gateway resource is associated with this subnet. A single public IP resource is created for the NAT gateway.  

For more information on **Virtual Network NAT** service and **NAT gateway** see:

* [What is Virtual Network NAT?](https://docs.microsoft.com/azure/virtual-network/nat-overview)

* [Designing virtual networks with NAT gateway resources](https://docs.microsoft.com/azure/virtual-network/nat-gateway-resource)

The following resources are deployed as part of the solution

### Microsoft.Network

Description

+ **publicIPAddresses**: Public IP address for NAT gateway.
+ **natGateways**: NAT gateway resource
+ **virtualNetworks**: Virtual network for NAT gateway.
  + **subnets**: Subnet for virtual network for NAT gateway.

`Tags: virtual network, vnet, nat, nat gateway`
