---
description: This template creates an Azure Firewall, FirewalllPolicy with Explicit Proxy and Network Rules with IpGroups. Also, includes a Linux Jumpbox vm setup
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azurefirewall-create-with-firewallpolicy-explicitproxy
languages:
- json
---
# Create a Firewall, FirewallPolicy with Explicit Proxy

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-explicitproxy/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-explicitproxy/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-explicitproxy/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-explicitproxy/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-explicitproxy/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/azurefirewall-create-with-firewallpolicy-explicitproxy/CredScanResult.svg)


[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-create-with-firewallpolicy-explicitproxy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fazurefirewall-create-with-firewallpolicy-explicitproxy%2Fazuredeploy.json)

This template deploys an Azure Firewall, Firewall Policy with Explicit Proxy and IP Groups in network rules.

With explicit proxy, customers will have the ability to define proxy settings in the browser to point to the firewall ILB, either manually configuring the browser with the IP address of the proxy or with a PAC (Proxy Auto Config) file.  In this mode, the traffic is sent to the Firewall using a UDR (user defined routing) configuration: the Firewall intercepts that traffic inline, and passes it to the destination.

`Tags: Microsoft.Network/ipGroups, Microsoft.Storage/storageAccounts, Microsoft.Network/routeTables, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Network/firewallPolicies, ruleCollectionGroups, Deny, Microsoft.Network/azureFirewalls`
