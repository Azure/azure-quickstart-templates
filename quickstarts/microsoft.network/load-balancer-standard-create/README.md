---
description: This template creates an Internet-facing load-balancer, load balancing rules, and three VMs for the backend pool with each VM in a redundant zone.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: load-balancer-standard-create
languages:
- json
- bicep
---
# Create a standard load-balancer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-standard-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-standard-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-standard-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-standard-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-standard-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-standard-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-standard-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-standard-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-standard-create%2Fazuredeploy.json)

**This template provides an example for how to deploy a Standard Load Balancer.**

The template creates and configures the following Azure resources:

- A standard Load Balancer
- A Network Security Group
- A Virtual Network
- Three NICs associated with the backend pool of the load balancer
- Three virtual machines with each vm in a different zone
- An Azure Bastion host to manage the virtual machines
- Create outbound rules and outbound pool for virtual machines

For more information about this template, see the quickstart articles:

- [Quickstart: Create a public load balancer to load balance VMs using the Azure portal](https://docs.microsoft.com/azure/load-balancer/quickstart-load-balancer-standard-public-portal)
- [Quickstart: Create a public load balancer to load balance VMs by using an ARM template](https://docs.microsoft.com/azure/load-balancer/quickstart-load-balancer-standard-public-template)

`Tags: Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension, Microsoft.Compute/virtualMachines, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/bastionHosts, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks`
