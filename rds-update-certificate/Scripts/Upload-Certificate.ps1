[cmdletbinding()]
param(
	[parameter(mandatory=$true)]
	[ValidateScript( { test-path $_ } )]
	[string]$pfxFilePath, 

	[parameter(mandatory=$true)]
	[ValidateIsNotNullOrEmpty()]
	[string]$certPassword,

	[parameter(mandatory=$true)]
	[ValidateIsNotNullOrEmpty()]
	[string]$vaultName,

	[parameter(mandatory=$true)]
	[ValidateIsNotNullOrEmpty()]
	[string]$secretName
)

$exportableFlag = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
$pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12

$x509 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection

$x509.Import($pfxFilePath, $certPassword, $exportableFlag)

$bytes = $x509.Export($pkcs12ContentType, $certPassword)

$secret = [System.Convert]::ToBase64String($bytes) | convertto-securestring -asplaintext -Force

Set-AzureKeyVaultSecret -VaultName $vaultName -Name $secretName -SecretValue $secret -ContentType 'application/x-pkcs12'