# Point-to-Site Gateway

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-point-to-site%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-point-to-site%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a VNet with a Gateway subnet. It then creates a public IP which is used to create a VPN Gateway in the VNet. Finally it configures a Dynamic Routing gateway with Point-to-Site configuration including VPN client address pool, client root certificates and revoked certificates and then creates the Gateway.

Modify parameters file to change default values.
