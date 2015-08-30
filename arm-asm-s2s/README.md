# Virtual Network with two Subnets and a VPN gateway

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Farm-asm-s2s%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Virtual Network with two subnets and a VPN gateway.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | Region where the resources will be deployed |
| enableBgp | Enable or disable BGP |
| gatewayType | VPN or ER |
| vpnType | Route based, or policy based |
| subscriptionId | Subscription ID |
| localGatewayName | Name for gateway connected to other VNet/on-prem network |
| localGatewayIpAddress | Public IP address for the gateway to connect to (from other VNet/on-prem) |
| localGatewayAddressPrefix | CIDR block for remote network |
| virtualNetworkName | Name for new virtual network |
| addressPrefix | CIDR block for new VNet |
| subnet1Name | Name for VM subnet |
| gatewaySubnet | Name for gatway subnet |
| subnet1Prefix | CIDR block for VM subnet |
| gatewaySubnetPrefix | CIDR block for gateway subnet |
| gatewayPublicIPName | Name for public IP object for the gateway |
| gatewayName | Name for the gateway connected to the new VNet |
| connectionName | Name for connection to be created |
| sharedKey | Shared key for IPSec connection |
