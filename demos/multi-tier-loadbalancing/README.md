---
description: This template deploys a Virtual Network, segregates the network through subnets, deploys VMs and configures load balancing
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: multi-tier-loadbalancing
languages:
- json
---
# Multi tier traffic manager, L4 ILB, L7 AppGateway

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/multi-tier-loadbalancing/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/multi-tier-loadbalancing/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/multi-tier-loadbalancing/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/multi-tier-loadbalancing/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/multi-tier-loadbalancing/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/multi-tier-loadbalancing/CredScanResult.svg)

This template showcases a sample of load balancing stack like L4 internetfacing , L7-Application Gateway and DNS-Traffic Manager load balancing types.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmulti-tier-loadbalancing%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmulti-tier-loadbalancing%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmulti-tier-loadbalancing%2Fazuredeploy.json)

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/availabilitySets, Microsoft.Network/applicationGateways, Microsoft.Network/trafficManagerProfiles, Microsoft.Network/trafficManagerProfiles/azureEndpoints`
