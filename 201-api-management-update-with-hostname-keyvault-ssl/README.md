# Azure API Management Service

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-update-with-hostname-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-update-with-hostname-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template shows an example of how to deploy an Azure API Management service with SSL Certificate from KeyVault.  
* This template assume that API Management service has an MSI Identity in Developer tier 
* It just references the Secret in KeyVault to be used as SSL Certificate.
* The template also assumes that API Management service identity has required permission on the KeyVault secret.