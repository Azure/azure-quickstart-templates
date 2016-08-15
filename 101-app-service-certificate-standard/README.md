# Create and assign a standard App Service Certificate

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-certificate-standard%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-certificate-standard%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

For more details on creating an App Service Certificate see [How to Create an App Service Certificate](https://azure.microsoft.com/en-us/documentation/articles/web-sites-purchase-ssl-web-site/).

In order to deploy this template, the pre-requisite Azure resources are given below:
1. A Key Vault (specified in 'existingKeyVaultId' parameter)
2. An App Service App (specified in 'existingAppName' parameter)

By default, 'Microsoft.CertificateRegistration' and 'Microsoft.Web' RPs don't have access to the Key Vault specified in the template hence you need to authorize these RPs by executing 
the following PowerShell commands before deploying the template:

Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId AZURE_SUBSCRIPTION_ID
Set-AzureRmKeyVaultAccessPolicy -VaultName KEY_VAULT_NAME -ServicePrincipalName f3c21649-0979-4721-ac85-b0216b2cf413 -PermissionsToSecrets get,set,delete
Set-AzureRmKeyVaultAccessPolicy -VaultName KEY_VAULT_NAME -ServicePrincipalName abfa0a7c-a6b6-4736-8310-5855508787cd -PermissionsToSecrets get

ServicePrincipalName parameter represents these RPs in user tenant and will remain same for all Azure subscriptions. This is a onetime operation. Once you have a configured a Key Vault properly, 
you can use it to store as many App Service Certificates as you want without executing these PowerShell commands again.You can go through the Key Vault documentation for more information:
https://azure.microsoft.com/en-us/documentation/articles/key-vault-get-started/

The Web App should be in the same resource group with 'rootHostName' and www subdomain assigned as custom domains.
https://azure.microsoft.com/en-us/documentation/articles/web-sites-custom-domain-name/