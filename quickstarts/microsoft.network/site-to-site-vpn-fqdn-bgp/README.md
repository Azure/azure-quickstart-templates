# Site-to-Site VPN between two Azure VNets with VPN Gateways in configuration active-active with BGP

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/site-to-site-vpn-fqdn-bgp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/site-to-site-vpn-fqdn-bgp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/site-to-site-vpn-fqdn-bgp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/site-to-site-vpn-fqdn-bgp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/site-to-site-vpn-fqdn-bgp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/site-to-site-vpn-fqdn-bgp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fsite-to-site-vpn-fqdn-bgp%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fsite-to-site-vpn-fqdn-bgp%2Fazuredeploy.json)


This template creates two Site-to-Site VPN tunnels between two Azure Virtual Networks. In each Azure VNet is deployed an Azure VPN Gateway in configuration active-active in availability zones. To establish the IPsec/IKE VPN tunnels, each Azure VPN Gateway resolves the FQDN of the remote peers to determine the public IP of the remote VPN Gateway.

The Azure VPN Gateway advertises through BGP the Azure Virtual network address space to the remote peer. Two different BGP sessions are established between the two Azure VPN Gateway, with transit through different IPsec tunnels.

## Network diagram

[![1]][1]

### Site-to-Site IPsec tunnels between the Azure VPN gateways:

[![2]][2]

At the end of deployment, the two Azure VMs in the two VNets,vm1 and vm2, can communicate through private IPs. 

[![3]][3]

## Note1 
- the template works as expected only in **Azure regions with availability zones**.
- VPN gateway supports two generations: **Generation1** and **Generation2**. The **VpnGw1AZ** gateway SKU is only available in **Generation1**.
- the IPsec / IKE policy is set to default


## Note2 
Before running the template deployment, set your custom values in the parameters file: 
- **sharedKey**: pre-shared key used for Site-to-Site VPN tunnels
- **adminUsername**: administrator username of the Azure VMs 
- **adminPassword**: administrator password of the Azure VMs




`Tags: Azure VPN, site-to-site`

<!--Image References-->

[1]: ./images/1.png "network diagram"
[2]: ./images/2.png "Azure VPN Gateways"
[3]: ./images/3.png "communication between VMs"

<!--Link References-->


