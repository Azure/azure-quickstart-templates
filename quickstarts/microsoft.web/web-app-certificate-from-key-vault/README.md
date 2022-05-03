# Deploy a Web App certificate from Key Vault secret and use it for creating SSL binding

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-certificate-from-key-vault/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-certificate-from-key-vault/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-certificate-from-key-vault/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-certificate-from-key-vault/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-certificate-from-key-vault/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-certificate-from-key-vault/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-certificate-from-key-vault%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-certificate-from-key-vault%2Fazuredeploy.json)

To deploy this template, you need to have the following resources:

1. A Key Vault (specified in 'existingKeyVaultId' parameter)
2. A Key Vault Secret containting a PFX certificate stored in base64 encoded format (PowerShell script is given below)
3. A Web App (specified in 'existingWebAppName' parameter)
4. The App Service Plan (serverFarm) resource identifier housing the Web App specified in step 3

By default, 'Microsoft.Azure.WebSites' Resource Provider (RP) doesn't have access to the Key Vault specified in the template hence you need to authorize it by executing
the following PowerShell commands before deploying the template:

```PowerShell
Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId AZURE_SUBSCRIPTION_ID
Set-AzureRmKeyVaultAccessPolicy -VaultName KEY_VAULT_NAME -ServicePrincipalName abfa0a7c-a6b6-4736-8310-5855508787cd -PermissionsToSecrets get
```

ServicePrincipalName parameter represents Microsoft.Azure.WebSites RP in user tenant and will remain same for all Azure subscriptions. This is a onetime operation. Once you have a configured a Key Vault properly,
you can use it for deploying as many certificates as you want without executing these PowerShell commands again. You can go through the Key Vault documentation for more information:

[https://azure.microsoft.com/en-us/documentation/articles/key-vault-get-started/](https://azure.microsoft.com/en-us/documentation/articles/key-vault-get-started/)

The Web App should be in the same resource group with 'hostname' assigned as a custom domain.

[https://azure.microsoft.com/en-us/documentation/articles/web-sites-custom-domain-name/](https://azure.microsoft.com/en-us/documentation/articles/web-sites-custom-domain-name/)

PowerShell script to upload certificate into a Key Vault Secret:

```PowerShell
$pfxFilePath = "PFX_CERTIFICATE_FILE_PATH" # Change this path
$pwd = "PFX_CERTIFICATE_PASSWORD"  # Change this password
$flag = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
$collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$collection.Import($pfxFilePath, $pwd, $flag)
$pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12
$clearBytes = $collection.Export($pkcs12ContentType)
$fileContentEncoded = [System.Convert]::ToBase64String($clearBytes)
$secret = ConvertTo-SecureString -String $fileContentEncoded -AsPlainText –Force
$secretContentType = 'application/x-pkcs12'
Set-AzureKeyVaultSecret -VaultName KEY_VAULT_NAME -Name KEY_VAULT_SECRET_NAME -SecretValue $Secret -ContentType $secretContentType # Change Key Vault name and Secret name
```
