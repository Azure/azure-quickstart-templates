# Network Interface in a Virtual Network with Public IP Address

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-networkinterface-with-publicip-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Network Inerface in a Virtual Network referencing a Public IP Address.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| dnsNameforPublicIP  | Unique DNS Name for the Public IP Address |
| location  | Azure region where the resource will be deployed to  |
| addressPrefix  | Address Prefix for the Virtual Network specified in the CIDR format  |
| subnetPrefix | Prefix for the Subnet specified in CIDR format |
| publicIPAddressType | Address Type of the Public IP Address - Dynamic or Static |

