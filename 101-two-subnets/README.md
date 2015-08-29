# Virtual Network with two Subnets

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-two-subnets%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Virtual Network with two subnets.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | Region where the resources will be deployed |
| vnetName | Name for the new virtual network |
| addressPrefix | Address prefix for the Virtual Network specified in CIDR format |
| subnet1Name | Name for first subnet |
| subnet1Prefix | Prefix for the Subnet-1 specified in CIDR format |
| subnet2Name | Name for second subnet |
| subnet2Prefix | Prefix for the Subnet-2 specified in CIDR format |
