# Deploy a Web App certificate from Key Vault secret and use it for creating SSL binding

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-certificate-from-key-vault%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-app-service-certificate-standard%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

In order to deploy this template, you need to have the following resources:  <br />
1. A Key Vault (specified in 'existingKeyVaultId' parameter) <br />
2. A Key Vault Secret containting a PFX certificate stored in base64 encoded format (PowerShell script is given below)  <br />
3. A Web App (specified in 'existingWebAppName' parameter)  <br />

By default, 'Microsoft.Web' Resource Provider (RP) doesn't have access to the Key Vault specified in the template hence you need to authorize it by executing 
the following PowerShell commands before deploying the template:  <br />

<I>
Login-AzureRmAccount  <br />
Set-AzureRmContext -SubscriptionId AZURE_SUBSCRIPTION_ID  <br />
Set-AzureRmKeyVaultAccessPolicy -VaultName KEY_VAULT_NAME -ServicePrincipalName abfa0a7c-a6b6-4736-8310-5855508787cd -PermissionsToSecrets get  <br />
</I>

ServicePrincipalName parameter represents Microsoft.Web RP in user tenant and will remain same for all Azure subscriptions. This is a onetime operation. Once you have a configured a Key Vault properly, 
you can use it for deploying as many certificates as you want without executing these PowerShell commands again. You can go through the Key Vault documentation for more information: <br />
https://azure.microsoft.com/en-us/documentation/articles/key-vault-get-started/

The Web App should be in the same resource group with 'hostname' assigned as a custom domain. <br />
https://azure.microsoft.com/en-us/documentation/articles/web-sites-custom-domain-name/

PowerShell script to upload certificate into a Key Vault Secret:  <br />
<I>
$pfxFilePath = "PFX_CERTIFICATE_FILE_PATH" # Change this path  <br />
$pwd = "PFX_CERTIFICATE_PASSWORD"  # Change this password  <br />
$flag = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable  <br />
$collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection   <br />
$collection.Import($pfxFilePath, $pwd, $flag)  <br />
$pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12  <br />
$clearBytes = $collection.Export($pkcs12ContentType)  <br />
$fileContentEncoded = [System.Convert]::ToBase64String($clearBytes)  <br />
$secret = ConvertTo-SecureString -String $fileContentEncoded -AsPlainText –Force  <br />
$secretContentType = 'application/x-pkcs12'  <br />
Set-AzureKeyVaultSecret -VaultName KEY_VAULT_NAME -Name KEY_VAULT_SECRET_NAME -SecretValue $Secret -ContentType $secretContentType # Change Key Vault name and Secret name <br />
</I>