$secretName = "nscakey"
$fileName = "C:\Users\chris\Source\Repos\DNCC\WPSetup\sshcerts\cert.pfx"

$fileContentBytes = get-content $fileName -Encoding Byte
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
$password = ""
# ConvertTo-SecureString -String "certpass" -Force -AsPlainText

$jsonObject = @"
{
"data": "$filecontentencoded",
"dataType" :"pfx",
"password" : "$password"
}
"@

$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes)

$secret = ConvertTo-SecureString -String $jsonEncoded -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName dncKeyVault -Name $secretName -SecretValue $secret

$certObj = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$certObj.Import( $fileName, $password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet);
Write-Host "Thumbprint: " $certObj.Thumbprint


#ConvertFrom-SecureString 