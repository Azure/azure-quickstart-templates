# Virtual Network with two Subnets

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-virtual-network%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Virtual Network with a single subnet

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | Region where the resources will be deployed |
| addressPrefix | Address prefix for the Virtual Network specified in CIDR format |
| subnetPrefix | Prefix for the Subnet-1 specified in CIDR format |
