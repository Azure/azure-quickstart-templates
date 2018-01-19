# VNET to VNET connection

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vnet-to-vnet-bgp%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vnet-to-vnet-bgp%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates two VNETs in the same location, each containing a subnet and Gateway subnet. It creates two public IPs which are used to create two VPN Gateways in the two VNETs, both with BGP enabled using private ASNs. Finally it establishes a BGP enabled connection between the two gateways.

The Autonomous System Numbers (ASNs) can be private or public.

Enter the Pre-shared Key as a parameter. A default one is provided in the Parameters file, but do not use this in Production!

You can also enter a specific Gateway SKU as a parameter; choose from the following:
* VpnGw1 (default)
* VpnGw2
* VpnGw3
* Standard (legacy)
* HighPerformance (legacy)

More info on the Gateway SKUs can be found here: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways#a-namegwskuagateway-skus