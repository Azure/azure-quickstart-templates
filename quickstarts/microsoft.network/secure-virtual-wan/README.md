# Azure Virtual WAN (vWAN) Multi-Hub Deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/secure-virtual-wan/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/secure-virtual-wan/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/secure-virtual-wan/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/secure-virtual-wan/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/secure-virtual-wan/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/secure-virtual-wan/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fsecure-virtual-wan%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fsecure-virtual-wan%2Fazuredeploy.json)

## Solution Overview

This template creates a fully functional Azure Virtual WAN (vWAN) environment with the following resources:

- Two distinct hubs in different regions
- One Premium Azure Firewall in each hub
- One Default Firewall Policy
- Four Azure Virtual Networks (VNET)
- Two VNET connections for each vWAN hub
- One Point-to-Site (P2S) VPN gateway in each hub
- One Site-to-Site (S2S) VPN gateway in each hub
- One Express Route gateway in each hub
- One Virtual Machine in each Virtual Network

## Solution

vWAN resource deployed is of type "Standard" with default full mesh connectivity.
This contains two Virtual Hubs in two different regions to provide a true any-to-any connectivity with Azure. Each Virtual Hub is secured by an Azure Firewall. The Hub Security Configuration is updated to use the Azure Firewall for Internet and Private Traffic. There are 4 Windows Server 2019 Virtual Machines that can be connected to by RDP. These can be used to perform network connectivity testing.

[Steps](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-point-to-site-azure-ad#device) on connecting to the Virtual WAN with a P2S VPN

The Default Azure Firewall Policy allows inbound RDP from the P2S VPN Client Address Pools to the four Virtual Networks. It also allows outbound *.microsoft.com, KMS Activation and [FQDN tags](https://docs.microsoft.com/en-us/azure/firewall/fqdn-tags#current-fqdn-tags) from the four Virtual Networks.

List of input parameters has been kept at the very minimum.
IP addressing scheme can be changed modifying the variables inside the template.

> [!NOTE]
> This template will create all the vWAN resources listed above, but will not create the customer side resources required for hybrid connectivity. After template deployment will be completed, user will need to install P2S VPN clients, create VPN branches (Local Sites) and connect Express Route circuits.

> [!NOTE]
> Private IP filtering is enabled but the use of two secure hubs does not currently support filtering inter-hub traffic. Branch to Virtual Network (B2V) or Virtual Network to Virtual Network (V2V) using the same regional hub is unaffected. More on known issues available [here](https://docs.microsoft.com/en-us/azure/virtual-wan/virtual-wan-point-to-site-azure-ad#device). However, hub to hub communication still works if private traffic filtering via Azure Firewall isn't enabled.

`Tags: Virtual WAN, vWAN, Hub, ExpressRoute, VPN, S2S, P2S, Routing`
