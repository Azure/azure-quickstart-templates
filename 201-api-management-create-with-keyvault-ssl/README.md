# Azure API Management Service

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-keyvault-ssl/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-keyvault-ssl/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-keyvault-ssl/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-keyvault-ssl/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-keyvault-ssl/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-keyvault-ssl/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-keyvault-ssl%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
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

PowerShell script to upload certificate into a Key Vault Secret:
```Powershell
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

