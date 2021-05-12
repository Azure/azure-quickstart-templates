# Cross-region Azure Load Balancer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/load-balancer-cross-region/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-cross-region%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fload-balancer-cross-region%2Fazuredeploy.json)

This template creates a:

* Two regional load balancers in regions of your choosing

* Cross-region load balancer

The template creates supporting public IP resources, virtual networks, and bastion hosts for management in each region.

Three Windows Server virtual machines are deployed in each region. The virtual machines are members of the backend pool of each regional load balancer.

IIS is installed with an extension. The default web page is replaced with a page displaying the computer name.

The regional load balancer front-ends are added as a member of the backend pool of the cross-region load balancer.

> [NOTE]
> Cross-region load balancer is currently in preview.
> This preview version is provided without a service level agreement, and it's not recommended for production workloads. Certain features might not be supported or might have constrained capabilities. 
> For more information, see [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/support/legal/preview-supplemental-terms/).

For more information on creating a regional, public Azure load balancer see [Quickstart: Create a public load balancer to load balance VMs by using an ARM template](https://docs.microsoft.com/azure/load-balancer/quickstart-load-balancer-standard-public-template).

For more information on cross-region load balancer, see [Cross-region load balancer (Preview)](https://docs.microsoft.com/azure/load-balancer/cross-region-overview).

`Tags: load balancer`
