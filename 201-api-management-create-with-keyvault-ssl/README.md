# Azure API Management Service

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template shows an example of how to deploy an Azure API Management service with SSL Certificate from KeyVault.  
* This template creates API Management service having an MSI Identity in Developer tier 
* Retrieves the MSI Identity of the API Management service and gives it GET permissions on the KeyVault Secrets.
* It then executes a second template on API Management to configure hostnames with Certificate references from KeyVault.

<P>
In order to deploy this template, you need to have the following resources: <br />
1. A Key Vault (specified in 'keyVaultName' parameter) <br />
2. A Key Vault secret having the Certificate(specified in 'keyVaultSecretsIdToCertificate' parameter) <br />
3. The Certificate need to be issued for the Domain you want to configure (specified in 'proxyCustomHostname' parameter) <br />
</P>

The Template expects the keyVaultSecretsIdToCertificate as https://constosovault.vault.azure.net/secrets/msitestingCert