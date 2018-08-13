$subscriptionId = $args[0]
$resourceGroupName = $args[1]
$managedInstanceName = $args[2]
$administratorLogin = $args[3]
$administratorLoginPassword = $args[4]
$certificateNamePrefix = $args[5]

function Ensure-Login () 
{
    $context = Get-AzureRmContext
    If($context.Subscription -eq $null)
    {
        Login-AzureRmAccount | Out-null
    }
}

Ensure-Login

$context = Get-AzureRmContext
If($context.Subscription.Id -ne $subscriptionId)
{
    #TODO check if subscription exists
    Select-AzureRmSubscription -SubscriptionId $subscriptionId  | Out-null
}

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