---
description: This template creates a global load balancer with a backend pool containing two regional load balancers. global load balancer is currently available in limited regions. The regional load balancers behind the global load balancer can be in any region.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: load-balancer-global
languages:
- bicep
- json
---
# Create a global load balancer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-cross-region%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-cross-region%2Fazuredeploy.json)

This template creates a:

* Two regional load balancers in regions of your choosing

* [Global load balancer](https://docs.microsoft.com/azure/load-balancer/cross-region-overview) in a region of your choosing

The template creates supporting public IP resources, virtual networks, and bastion hosts for management in each region.

Three Windows Server virtual machines are deployed in each region. The virtual machines are members of the backend pool of each regional load balancer.

IIS is installed with an extension. The default web page is replaced with a page displaying the computer name.

The regional load balancer front-ends are added as a member of the backend pool of the global load balancer.

For more information on creating a regional, public Azure load balancer see [Quickstart: Create a public load balancer to load balance VMs by using an ARM template](https://docs.microsoft.com/azure/load-balancer/quickstart-load-balancer-standard-public-template).

For more information on global load balancer, see [Global load balancer (Preview)](https://docs.microsoft.com/azure/load-balancer/cross-region-overview).

`Tags: load balancer, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension, Microsoft.Compute/virtualMachines, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/bastionHosts, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/loadBalancers/backendAddressPools`
