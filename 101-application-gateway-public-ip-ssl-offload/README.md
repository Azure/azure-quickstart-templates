# Application Gateway With Public IP and HTTPS Listener

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-application-gateway-public-ip-ssl-offload/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-application-gateway-public-ip-ssl-offload/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-application-gateway-public-ip-ssl-offload/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-application-gateway-public-ip-ssl-offload/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-application-gateway-public-ip-ssl-offload/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-application-gateway-public-ip-ssl-offload/CredScanResult.svg" />&nbsp;

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-public-ip-ssl-offload%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-public-ip-ssl-offload%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template creates an Application Gateway, Public IP address for the Application Gateway, and the Virtual Network in which Application Gateway is deployed. Also configures Application Gateway for Ssl Offload and Load balancing with Two backend servers. 

Tip: To get the certData from pfx file in PowerShell you can use this: [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("path to pfx file"))

