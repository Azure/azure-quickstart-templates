# Azure DNS Private resolver

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazure-dns-private-resolver%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazure-dns-private-resolver%2Fazuredeploy.json)

This template will deploy the **Azure DNS Private resolver** with required resources such as Virtual Network, subnets for Inbound and Outbound endpoints, private resolver & its endpoints, forwarding rulesets, and forwarding rules. It deploys the private resolver and the virtual network in the same location mentioned in the parameter.

# Overview and deployed resources

A virtual network is deployed with two subnets, inbound and outbound. The dns resolver resource is then deployed in this virtual network along with inbound, outbound endpoints, forwarding ruleset and forwarding rules with target DNS servers. The ruleset will be linked to the outbound endpoint for conditional forwarding.

### Microsoft.Network/dnsresolvers

Description
- **virtualNetwork**: Virtual network for dnsresolver
    -  **subnets:** subnet for inbound and ounbound endpoints.
- **dnsresolvers:** The DNS private resolver
- **resolverEndpoint:** Resolver's Inbound & Outbound Endpoint.
- **forwardingRuleSet:** Forwarding Ruleset
- **forwardingRule:** Forwarding rules with the target DNS servers for conditional forwarding.

`Tags: dns resolver, private resolver, private dns resolver,Microsoft.Network/dnsresolvers`