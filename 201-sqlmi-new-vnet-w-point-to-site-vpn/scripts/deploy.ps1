$managedInstanceName = args[0]
$administratorLogin = args[1]
$administratorLoginPassword = args[2]
$certificateNamePrefix = args[3]

$certificate = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject ("CN=$certificateNamePrefix"+"P2SRoot") -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

$certificateThumbprint = $certificate.Thumbprint

New-SelfSignedCertificate -Type Custom -DnsName ($certificateNamePrefix+"ChildP2S") -KeySpec Signature `
    -Subject ("CN=$certificateNamePrefix"+"ChildP2S") -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")  

$publicRootCertData = [Convert]::ToBase64String((Get-Item cert:\currentuser\my\$certificateThumbprint).RawData)

Write-Host $publicRootCertData