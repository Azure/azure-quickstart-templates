---
description: Deploy a hub-spoke network topology with NAT gateway, Azure Firewall, and virtual machine
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: nat-gateway-hub-spoke-firewall
languages:
- bicep
- json
---
# Hub-Spoke Network with NAT Gateway and Azure Firewall

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-hub-spoke-firewall/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-hub-spoke-firewall/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-hub-spoke-firewall/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-hub-spoke-firewall/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-hub-spoke-firewall/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-hub-spoke-firewall/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/nat-gateway-hub-spoke-firewall/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnat-gateway-hub-spoke-firewall%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnat-gateway-hub-spoke-firewall%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnat-gateway-hub-spoke-firewall%2Fazuredeploy.json)

This template deploys a **hub-spoke network topology** with **Azure Firewall**, **NAT gateway**, and supporting resources.

## Overview

This template implements a hub-spoke network architecture that demonstrates secure network connectivity patterns in Azure. The solution includes a hub virtual network with centralized security services (Azure Firewall and Azure Bastion) and a spoke virtual network with workload resources. The NAT gateway provides secure outbound internet connectivity for resources in the hub network.

The hub-spoke topology is a common enterprise networking pattern that provides:

- Centralized security and connectivity services in the hub
- Isolated workload environments in the spokes
- Controlled communication between spokes through the hub
- Efficient use of shared services

## Architecture

The template creates the following network topology:

```text
Internet
    |
[NAT Gateway] ← [Azure Firewall] ← [Azure Bastion]
    |              |                    |
[Hub VNet] ←------ Peering -------→ [Spoke VNet]
                                        |
                                   [Virtual Machine]
```

## Deployed resources

The following resources are deployed as part of the solution.

### Microsoft.Network

- **virtualNetworks**: Hub and spoke virtual networks with appropriate subnets
  - Hub VNet (10.0.0.0/16) with AzureFirewallSubnet, AzureBastionSubnet, and general subnet
  - Spoke VNet (10.1.0.0/16) with private subnet for workloads
- **virtualNetworkPeerings**: Bidirectional peering between hub and spoke networks
- **natGateways**: NAT gateway for secure outbound internet connectivity
- **publicIPAddresses**: Public IP addresses for NAT gateway, Azure Firewall, and Azure Bastion
- **azureFirewalls**: Azure Firewall for network security and traffic filtering
- **firewallPolicies**: Firewall policy with network rules for spoke-to-internet traffic
- **bastionHosts**: Azure Bastion for secure RDP/SSH access to virtual machines
- **routeTables**: Route table directing spoke traffic through the Azure Firewall
- **networkSecurityGroups**: Network security group for virtual machine protection
- **networkInterfaces**: Network interface for the virtual machine

### Microsoft.Compute

- **virtualMachines**: Ubuntu virtual machine deployed in the spoke network

## Parameters

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| location | string | resourceGroup().location | Location for all resources |
| resourcePrefix | string | natfw-{uniqueString} | Resource name prefix for all deployed resources |
| adminUsername | string | azureuser | Admin username for the virtual machine |
| authenticationType | string | password | Authentication type (password or sshPublicKey) |
| adminPasswordOrKey | securestring | - | SSH Key or password for the virtual machine |

## Security Features

- **Azure Firewall**: Centralized network security with stateful traffic filtering
- **Azure Bastion**: Secure RDP/SSH access without exposing VMs to the internet
- **NAT Gateway**: Secure outbound internet connectivity with static public IP
- **Network Segmentation**: Isolation between hub and spoke networks
- **Route Tables**: Forced tunneling of spoke traffic through the firewall

## Use Cases

This template is ideal for:

- Enterprise hub-spoke network architectures
- Secure development and testing environments
- Centralized security and connectivity services
- Demonstrating Azure networking best practices
- Network security proof-of-concepts

For more information on the deployed networking services, see:

- [What is Azure Firewall?](https://docs.microsoft.com/azure/firewall/overview)
- [What is Virtual Network NAT?](https://docs.microsoft.com/azure/virtual-network/nat-overview)
- [What is Azure Bastion?](https://docs.microsoft.com/azure/bastion/bastion-overview)
- [Hub-spoke network topology in Azure](https://docs.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)

`Tags: hub-spoke, virtual network, vnet, nat, nat gateway, azure firewall, bastion, virtual machine, network security, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworkPeerings, Microsoft.Network/natGateways, Microsoft.Network/azureFirewalls, Microsoft.Network/firewallPolicies, Microsoft.Network/bastionHosts, Microsoft.Network/routeTables, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines`
