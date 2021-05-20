# Azure Virtual WAN (vWAN) Multi-Hub Deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-wan-with-all-gateways/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-wan-with-all-gateways/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-wan-with-all-gateways/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-wan-with-all-gateways/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-wan-with-all-gateways/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-wan-with-all-gateways/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvirtual-wan-with-all-gateways%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvirtual-wan-with-all-gateways%2Fazuredeploy.json)

## Solution Overview

This template creates a fully functional Azure Virtual WAN (vWAN) environment with the following resources:

- Two distinct hubs in different regions
- Four Azure Virtual Networks (VNET)
- Two VNET connections for each vWAN hub
- One Point-to-Site (P2S) VPN gateway in each hub
- One Site-to-Site (S2S) VPN gateway in each hub
- One Express Route gateway in each hub

## Architecture

vWAN resource deployed is of type "Standard" with default full mesh connectivity.
The scenario implemented is exactly the one referenced in the Azure Virtual WAN documentation article below:

[Azure vWAN Routing Scenario: any-to-Any](https://docs.microsoft.com/azure/virtual-wan/scenario-any-to-any)

![Figure 1](images/azurevirtualwanarchitecturefigure1.jpg)

List of input parameters has been kept at the very minimum.
IP addressing scheme can be changed modifying the variables inside the template, values have been provided based on the architecture diagram above.

> [!NOTE]
> This template will create all the vWAN resources listed above, but will not create the customer side resources required for hybrid connectivity. After template deployment will be completed, user will need to create P2S VPN clients, VPN branches (Local Sites) and connect Express Route circuits.

## Successful Deployment

Once the ARM deployment of the template will be completed, you should see something similar to the image below:

![Figure 3](images/deploymentcompleteinazureportal.jpg)

## ARM resources

Additionally, inside the Resource Group the following resources will be created:

![Figure 4](images/vwanresourcesinazureportal.jpg)

`Tags: Virtual WAN, vWAN, Hub, ExpressRoute, VPN, S2S, P2S, Routing`
