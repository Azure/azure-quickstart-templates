# Create and assign a wildcard App Service Certificate

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-certificate-wildcard/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-certificate-wildcard/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-certificate-wildcard/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-certificate-wildcard/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-certificate-wildcard/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-certificate-wildcard/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fapp-service-certificate-wildcard%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fapp-service-certificate-wildcard%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fapp-service-certificate-wildcard%2Fazuredeploy.json)

For more details on creating an App Service Certificate see [How to Create an App Service Certificate](https://azure.microsoft.com/en-us/documentation/articles/web-sites-purchase-ssl-web-site/).

In order to deploy this template, you need to have the following resources:
1. A Key Vault (specified in 'existingKeyVaultId' parameter)
2. An App Service App(specified in 'existingAppName' parameter)
3. An App Service Domain (specified in 'rootHostName' parameter)

By default, 'Microsoft.CertificateRegistration' and 'Microsoft.Web' RPs don't have access to the Key Vault specified in the template hence you need to authorize these RPs by executing 
the following PowerShell commands before deploying the template:  

```powershell
Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId AZURE_SUBSCRIPTION_ID
Set-AzureRmKeyVaultAccessPolicy -VaultName KEY_VAULT_NAME -ServicePrincipalName f3c21649-0979-4721-ac85-b0216b2cf413 -PermissionsToSecrets get,set,delete
Set-AzureRmKeyVaultAccessPolicy -VaultName KEY_VAULT_NAME -ServicePrincipalName abfa0a7c-a6b6-4736-8310-5855508787cd -PermissionsToSecrets get
```

ServicePrincipalName parameter represents these RPs in user tenant and will remain same for all Azure subscriptions. This is a onetime operation. Once you have a configured a Key Vault property, you can use it to store as many App Service Certificates as you want without executing these PowerShell commands again. You can go through the Key Vault documentation for more information:  
https://azure.microsoft.com/en-us/documentation/articles/key-vault-get-started/

The Web App and domain resources need to be in the same resource group. The Web App should have 'rootHostName' and www subdomain assigned as custom domains.  
https://azure.microsoft.com/en-us/documentation/articles/custom-dns-web-site-buydomains-web-app/  
https://azure.microsoft.com/en-us/documentation/articles/web-sites-custom-domain-name/



