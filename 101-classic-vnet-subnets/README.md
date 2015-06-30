# Classic Virtual Network (V1) with two Subnets

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-classic-vnet-subnets%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Classic Virtual Network (V1) with two subnets. Exactly the same as the 101-two-subnets template but using the correct provider and parameters for V1 VNets.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | Region where the resources will be deployed |
| Vnet-Name | Name for the virtual network to be created |
| Vnet-CIDR | Address prefix for the Virtual Network specified in CIDR format |
| Subnet1-Name | Name for the first Subnet within the Vnet |
| Subnet1-CIDR | Prefix for the Subnet-1 specified in CIDR format |
| Subnet2-Name | Name for the second Subnet within the Vnet |
| Subnet2-CIDR | Prefix for the Subnet-2 specified in CIDR format |
