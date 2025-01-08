---
description: This template creates a standard internal Azure Load Balancer with a rule load-balancing port 80
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: internal-loadbalancer-create
languages:
- bicep
- json
---
# Create a standard internal load balancer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/internal-loadbalancer-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/internal-loadbalancer-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/internal-loadbalancer-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/internal-loadbalancer-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/internal-loadbalancer-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/internal-loadbalancer-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/internal-loadbalancer-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Finternal-loadbalancer-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Finternal-loadbalancer-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Finternal-loadbalancer-create%2Fazuredeploy.json)

This template creates a standard internal Azure Load Balancer with backend pool containing two virtual machines. The Azure Load Balancer is assigned a static IP in the Virtual Network and is configured to load balance on Port 80. Health probes are configured to check the status of the virtual machines.

![Diagram of internal load balancer with backend pool of virtual machines.](images/internalLoadBalancerCreate.png)

As part of the deployment, Azure Bastion is deployed for virtual machine management, and NAT Gateway is deployed for outbound connectivity. This template also deploys a Storage Account, Virtual Network & subnets, and network interfaces.

To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/load-balancer/quickstart-load-balancer-standard-internal-bicep.md) article.

Outbound rules are not created as part of this template.  For more information on providing outbound connectivity to the backend pool see, [What is Virtual Network NAT?](https://docs.microsoft.com/azure/virtual-network/nat-overview).

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/networkInterfaces, Microsoft.Network/loadBalancers`