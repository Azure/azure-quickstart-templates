---
description: Deploy Azure Firewall with DDoS Protection Plan
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: ddos-protection-azurefirewall
languages:
- bicep
- json
---
# Azure Firewall with DDoS Protection

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/ddos-protection-azurefirewall/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/ddos-protection-azurefirewall/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/ddos-protection-azurefirewall/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/ddos-protection-azurefirewall/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/ddos-protection-azurefirewall/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/ddos-protection-azurefirewall/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/ddos-protection-azurefirewall/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fddos-protection-azurefirewall%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fddos-protection-azurefirewall%2Fazuredeploy.json)

This template deploys an **Azure Firewall** with **DDoS Protection Plan** and supporting resources.

## Overview

This template is a resource manager implementation of a quickstart for deploying Azure Firewall with DDoS Protection. A Windows Server virtual machine is deployed to the workload subnet that routes traffic through the Azure Firewall. The virtual network and public IP addresses are protected by the DDoS Protection Plan. To learn more about how to deploy the template, see the [quickstart](https://learn.microsoft.com/azure/ddos-protection/tutorial-protect-resources-cli) article.

For more information on **Azure Firewall** and **DDoS Protection** see:

- [What is Azure Firewall?](https://docs.microsoft.com/azure/firewall/overview)
- [What is Azure DDoS Protection?](https://docs.microsoft.com/azure/ddos-protection/ddos-protection-overview)
- [Azure Firewall architecture overview](https://docs.microsoft.com/azure/firewall/firewall-architecture)

## Deployed resources

The following resources are deployed as part of the solution.

### Microsoft.Network

- **ddosProtectionPlans**: DDoS Protection Plan for enhanced network protection.
- **publicIPAddresses**: Public IP addresses for Azure Firewall and virtual machine with DDoS Protection enabled.
- **routeTables**: Route table to direct traffic through the Azure Firewall.
- **virtualNetworks**: Virtual network with DDoS Protection Plan association.
  - **subnets**: Azure Firewall subnet and workload subnet for virtual machine.
- **firewallPolicies**: Azure Firewall policy with network, application, and DNAT rule collections.
  - **ruleCollectionGroups**: Rule collection groups for network, application, and DNAT rules.
- **azureFirewalls**: Azure Firewall resource with policy association.
- **networkInterfaces**: Network interface for virtual machine.

### Microsoft.Compute

- **virtualMachines**: Windows Server virtual machine for testing firewall rules.

## Important Cost Information

⚠️ **WARNING**: This template creates Azure resources with significant costs:

- **DDoS Protection Plan**: ~$2,944/month
- **Azure Firewall**: ~$1.25/hour (~$900/month)
- **Virtual Machine**: Additional compute costs

**Total estimated cost**: ~$3,800+/month

Be sure to delete the resource group after testing to avoid ongoing charges.

## Architecture

```text
Internet
   │
   ▼
[DDoS Protection Plan]
   │
   ▼
[Azure Firewall] ──── [Firewall Policy]
   │                      │
   │                   [Rules Collections]
   ▼
[Virtual Network]
   │
   ├── AzureFirewallSubnet
   │   └── [Azure Firewall]
   │
   └── WorkloadSubnet
       └── [Virtual Machine] ──── [Route Table]
```

## Template Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| location | Location for all resources | resourceGroup().location |
| virtualNetworkAddressPrefix | Virtual network address prefix | 10.1.0.0/16 |
| azureFirewallSubnetPrefix | Azure Firewall subnet address prefix | 10.1.1.0/26 |
| workloadSubnetPrefix | Workload subnet address prefix | 10.1.2.0/24 |
| adminUsername | Admin username for the virtual machine | azureuser |
| adminPassword | Admin password for the virtual machine | (required) |
| vmSize | Size of the virtual machine | Standard_D2s_v3 |
| resourcePrefix | Name prefix for all resources | fw-ddos |
| dnsLabelPrefix | DNS label prefix for public IP addresses | (auto-generated) |

## Outputs

- **firewallPublicIP**: Public IP address of the Azure Firewall
- **firewallFQDN**: Fully qualified domain name of the Azure Firewall
- **vmPublicIP**: Public IP address of the virtual machine
- **vmFQDN**: Fully qualified domain name of the virtual machine
- **firewallPrivateIP**: Private IP address of the Azure Firewall
- **virtualNetworkName**: Name of the virtual network
- **ddosProtectionPlanId**: Resource ID of the DDoS Protection Plan
- **adminUsername**: Admin username for the virtual machine
- **rdpConnectionString**: RDP connection string for the virtual machine

`Tags: azure firewall, ddos protection, network security, virtual network, firewall policy, Microsoft.Network/ddosProtectionPlans, Microsoft.Network/publicIPAddresses, Microsoft.Network/routeTables, Microsoft.Network/virtualNetworks, Microsoft.Network/firewallPolicies, Microsoft.Network/azureFirewalls, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines`
