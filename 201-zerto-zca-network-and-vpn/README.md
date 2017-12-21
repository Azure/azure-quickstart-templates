# Deploy Zerto Virtual Replication to Azure with a VPN

This template deploys the Zerto Cloud Appliance (ZCA) to Azure. It deploys a virtual network, public ip, network interface and a ZCA virtual machine. 

It also configures an [Azure VPN Gateway](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal) to create a site-to-site VPN connection between the Azure Virtual Network and your local on-premises network.


1. [azuredeploy.json](./azuredeploy.json)


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2FZerto%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
