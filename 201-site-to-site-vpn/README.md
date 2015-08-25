# Site to Site VPN Connection

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-site-to-site-vpn%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template will create a Virtual Network, a subnet for the network, a Virtual Netowork Gateway and Connection to your network outside of Azure (defined as your `local` network). This could be anything such as your on-premises network and can even be used with other cloud networks such as [AWS Virtual Private Cloud](https://github.com/sedouard/aws-vpc-to-azure-vnet). It also provisions an Ubuntu instance attached to the Azure Virtual Network so that you can test connectivity.

Please note that you must have a Public IP for your other network's VPN gateway and cannot be behind an NAT.

Although only the parameters in [azuredeploy-parameters.json](./azure-deploy-parameters.json) are necessary, you can override the defaults of any of the template parameters below:

| Name   | Description    |
|:--- |:---|
| location | Region where the resources will be deployed |
| vpnType | Route based, or policy based |
| subscriptionId | Subscription ID |
| localGatewayName | Name for gateway connected to other Network |
| localGatewayIpAddress | Public IP address of other network Gateway |
| localAddressPrefix | CIDR block of other network address space |
| virtualNetworkName | Name for new virtual network |
| azureVNetAddressPrefix | CIDR block for new Azure VNet |
| subnetName | Name for Azure VM subnet |
| subnetPrefix | CIDR block for Azure VM subnet |
| gatewaySubnet | Name for gatway subnet |
| gatewaySubnetPrefix | CIDR block for Azure gateway subnet |
| gatewayPublicIPName | Name for public IP resource for the Azure gateway |
| gatewayName | Name for the gateway connected to the new VNet |
| connectionName | Name for the new connection between Azure VNet and other network |
| vmName | Virtual Machine Name |
| vmSize | Shared key for IPSec connection |
| adminUsername | Username for test Virtual Machine |
| adminPassword | Password for test Virtual Machine |
| imagePublisher | VM Image publisher |
| imageOffer | VM Image offer |
| imageSKU | VM Image SKU |
| newStorageAccountName | Storage Account Name for VM Disk |
| storageAccountType | Storage Account Type for VM Disk |
