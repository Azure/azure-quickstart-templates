# Azure API Management Service

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-hostname-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-hostname-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template shows an example of how to deploy an Azure API Management service with SSL Certificate from KeyVault.  
* This template creates API Management service having an MSI Identity in Developer tier 
* Retrieves the MSI Identity of the API Management service and gives it GET permissions on the KeyVault Secrets.
* It then executes a second template on API Management to configure hostnames with Certificate references from KeyVault.

The Template expects the keyVaultSecretsIdToCertificate as https://constosovault.vault.azure.net/secrets/msitestingCert