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
| virtualNetworkName  | Name of the Virtual Network  |
| publicIPAddressName  | Name of the Public IP Address that will be associated with the Load Balancer |
| addressPrefix  | Address Prefix for the Virtual Network specified in the CIDR format  |
| subnetName | Name of the Subnet |
| subnetPrefix | Prefix for the Subnet specified in CIDR format |
| publicIPAddressType | Address Type of the Public IP Address - Dynamic or Static |
| loadBalancerName | Name of the Load Balancer |
| nicName | Name of the NIC |
