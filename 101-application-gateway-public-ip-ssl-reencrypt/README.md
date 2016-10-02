# Application Gateway With Public IP, HTTPS Listener and HTTPS Backend Pool

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-public-ip-ssl-offload%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-public-ip-ssl-offload%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates an Application Gateway, Public IP address for the Application Gateway, and the Virtual Network in which Application Gateway is deployed. Also configures Application Gateway for Ssl Offload and Load balancing with Two backend servers. 
Additionally, it also configures the backend pool to connect to the backend IPs via SSL using the public key cert data provided.

Tip: To get the certData from pfx file in PowerShell you can use this: [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("path to pfx file"))
