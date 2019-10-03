# Azure API Management Service

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-reference-keyvault/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-reference-keyvault/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-reference-keyvault/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-reference-keyvault/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-reference-keyvault/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-reference-keyvault/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-reference-keyvault%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-reference-keyvault%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template shows an example of how to deploy an Azure API Management service with SSL Certificate from [KeyVault as Resource Manager Reference]((https://azure.microsoft.com/en-us/documentation/articles/resource-manager-keyvault-parameter/).

<P>
In order to deploy this template, you need to have the following resources: <br />
1. A Key Vault <br />
2. An ssl certificate issued for the domain that you want to configure proxy for. This can be a self-signed certificate.<br />
3. You will need to allow Azure Resource Manager access to the KeyVault <br />
</P>

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

