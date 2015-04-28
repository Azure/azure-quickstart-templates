# Load Balancer with Inbound NAT Rule

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Load Balancer, Public IP address for the Load balancer, Virtual Network, Network Interface in the Virtual Network & a NAT Rule in the Load Balancer that is used by the Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| dnsNameforLBIP  | Unique DNS Name for the Load Balancer  |
| location  | Azure region where the resource will be deployed to  |
| addressPrefix  | Address Prefix for the Virtual Network specified in the CIDR format  |
| subnetPrefix | Prefix for the Subnet specified in CIDR format |
| publicIPAddressType | Address Type of the Public IP Address - Dynamic or Static |
