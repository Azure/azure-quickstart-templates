# Update certificates in RDS deployment

This template imports a PFX certificate from Azure Key Vault and configures RDS roles to use the certificate.

Click the button below to deploy:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmmarch%2Fazure-quickstart-templates%2Fmaster%2Frds-update-certificate%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmmarch%2Fazure-quickstart-templates%2Fmaster%2Frds-update-certificate%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Pre-Requisites

1. A PFX  certificate must be uploaded to an Azure Key Vault in tenants' subscription  and stored as a secret with content type 'application/x-pkcs12'
(see https://azure.microsoft.com/en-us/documentation/articles/key-vault-get-started and http://stackoverflow.com/questions/33728213/how-to-store-pfx-certificate-in-azure-key-vault)

	Sample powershell (alternatively see Scripts\Upload-Certificate.ps1):
	```
	$pfxFilePath = "c:\certificate.pfx"
	$certPassword = "B@kedPotat0"
	$vaultName = "myVault"
	$secretName = "certificate"

	$exportableFlag = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
	$pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12
	$x509 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
	$x509.Import($pfxFilePath, $certPassword, $exportableFlag)
	$bytes = $x509.Export($pkcs12ContentType, $certPassword)
	$secret = [System.Convert]::ToBase64String($bytes) | convertto-securestring -asplaintext -Force

	Set-AzureKeyVaultSecret -VaultName $vaultName -Name $secretName -SecretValue $secret -ContentType 'application/x-pkcs12'
	```
	You will need 1) Azure Key Vault name, and 2) secret name from this step to be supplied as parameters to Template.

2. A Service Principal must be created with permissions to access the key Vault
(see https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/)

	Sample powershell (alternatively see Scripts\New-ServicePrincipal.ps1):
	```
	$appPassword = "St@ffedPotat0"
	$uri = "https://www.contoso.com/script"   #  a valid formatted URL, not validated for single-tenant deployments
	$vaultName = "myVault"   #  same as in step #1 above

	$app = New-AzureRmADApplication -DisplayName "script" -HomePage $uri -IdentifierUris $uri -password $appPassword
	$sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

	Set-AzureRmKeyVaultAccessPolicy -vaultname $vaultName -serviceprincipalname $sp.ServicePrincipalName -permissionstosecrets list,get
	```

	You will need 1) application id ($app.ApplicationId), and 2) the password used abouve as parameters to the Template.  You will also need your tenant Id, to get tenant Id run the following powershell:
	```
	$tenantId = (get-azurermsubscription).TenantId | select -Unique
	```

## The Template

`<rdsRole>` parameter specifies which RDS role to configure the certificate for; it can be either of the four (see documentation for Set-RDCertificate cmdlet at https://technet.microsoft.com/en-us/library/jj215464.aspx):
```
{RDGateway | RDWebAccess | RDRedirector | RDPublishing}
```
If "All" is specified, then same certificate will be applied for all four roles.

Template performs the following steps:
+ downloads certificate from the key vault;
+ invokes Set-RDCertificate powershell cmdlet to apply the certificate.

