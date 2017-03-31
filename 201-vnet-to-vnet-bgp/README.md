# VNET to VNET connection

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vnet-to-vnet-bgp%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vnet-to-vnet-bgp%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates two VNETs in the same location, each containing a subnet and Gateway subnet. It creates two public IPs which are used to create two VPN Gateways in the two VNETs, both with BGP enabled using private ASNs. Finally it establishes a BGP enabled connection between the two gateways.

The Autonomous System Numbers (ASNs) can be private or public

Enter the Pre-shared Key as a parameter