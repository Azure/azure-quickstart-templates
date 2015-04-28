# Load Balancer with Inbound NAT Rule

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Load Balancer, Public IP address for the Load balancer, Virtual Network, Network Interface in the Virtual Network & a NAT Rule in the Load Balancer that is used by the Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location  | Azure region where the resource will be deployed to  |
| virtualNetworkName  | Name of the Virtual Network  |
| nicName | Name of the NIC |
| loadBalancerName | Name of the Load Balancer |
| addressPrefix | Prefix for the address in CIDR format |
| subnetName | Name of the Subnet |
| subnetPrefix | Prefix for the subnet in CIDR format |



