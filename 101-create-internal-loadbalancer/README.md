# Load Balancer with Inbound NAT Rule

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2F101-create-internal-loadbalancer%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


Built by: [kenazk](https://github.com/kenazk)

This template allows you to create a Load Balancer, Public IP address for the Load balancer, Virtual Network, Network Interface in the Virtual Network & a NAT Rule in the Load Balancer that is used by the Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location  | Azure region where the resource will be deployed to  |
| addressPrefix | Prefix for the address in CIDR format |
| subnetPrefix | Prefix for the subnet in CIDR format |



