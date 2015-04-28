# Network Interface in a Virtual Network with Public IP Address

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Network Inerface in a Virtual Network referencing a Public IP Address.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| dnsNameforPublicIP  | Unique DNS Name for the Public IP Address |
| location  | Azure region where the resource will be deployed to  |
| virtualNetworkName  | Name of the Virtual Network  |
| publicIPAddressName  | Name of the Public IP Address that will be associated with the Load Balancer |
| addressPrefix  | Address Prefix for the Virtual Network specified in the CIDR format  |
| subnetName | Name of the Subnet |
| subnetPrefix | Prefix for the Subnet specified in CIDR format |
| publicIPAddressType | Address Type of the Public IP Address - Dynamic or Static |
| nicName | Name of the NIC |
