---
description: This template provisions Azure DNS Private Resolver in a virtual network with required forwarding ruleset and rules. It creates a new virtual network with two subnets, and deploy Azure DNS Private Resolver in this VNET.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-dns-private-resolver
languages:
- json
- bicep
---
# Azure DNS Private Resolver

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azure-dns-private-resolver/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azure-dns-private-resolver/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azure-dns-private-resolver/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azure-dns-private-resolver/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azure-dns-private-resolver/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azure-dns-private-resolver/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azure-dns-private-resolver/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazure-dns-private-resolver%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazure-dns-private-resolver%2Fazuredeploy.json)

This template will deploy **Azure DNS Private resolver** with required resources such as Virtual Network, subnets (for Inbound and Outbound endpoints), DNS private resolver endpoints, forwarding rulesets, and forwarding rules. It deploys the private resolver and the virtual network in the same location mentioned in the parameter.

# Overview and deployed resources

A virtual network is deployed with two subnets that will be used for resolver's inbound and outbound endpoint. The dns resolver resource is then deployed in this virtual network along with inbound, outbound endpoints, forwarding ruleset and forwarding rules with target DNS servers. The ruleset will be linked to the outbound endpoint for conditional forwarding.

For more information on **Azure DNS Private Resolver**
- [What is Azure DNS Private Resolver](https://docs.microsoft.com/azure/dns/dns-private-resolver-overview)

### Microsoft.Network/dnsresolvers

Description
- **virtualNetwork**: Virtual network for dnsresolver
    -  **subnets:** subnet for inbound and ounbound endpoints.
- **dnsresolvers:** The DNS private resolver
- **resolverEndpoint:** Resolver's Inbound & Outbound Endpoint.
- **forwardingRuleSet:** Forwarding Ruleset
- **forwardingRule:** Forwarding rules with the target DNS servers for conditional forwarding.

## Deployment steps

The virtual network and DNS private resolver location should be chosen as one of the supported locations for DNS private resolver. More information [here.](https://docs.microsoft.com/azure/dns/dns-private-resolver-overview#regional-availability)
```Bash
az deployment group create --resource-group <resourcegroup name> --template-file <bicep file location>
```

`Tags: dns resolver, private resolver, private dns resolver, Microsoft.Network, Microsoft.Network/dnsresolvers`