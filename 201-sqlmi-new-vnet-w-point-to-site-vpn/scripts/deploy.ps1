$parameters = $args[0]
$scriptUrlBase = $args[1]

$subscriptionId = $parameters['subscriptionId']
$resourceGroupName = $parameters['resourceGroupName']
$certificateNamePrefix = $parameters['certificateNamePrefix']
$location = $parameters['location']

$parameters.Remove('subscriptionId')
$parameters.Remove('resourceGroupName')
$parameters.Remove('certificateNamePrefix')

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
    # select subscription
    Write-Host "Selecting subscription '$subscriptionId'";
    Select-AzureRmSubscription -SubscriptionId $subscriptionId  | Out-null
}

$certificate = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject ("CN=$certificateNamePrefix"+"P2SRoot") -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

$certificateThumbprint = $certificate.Thumbprint

New-SelfSignedCertificate -Type Custom -DnsName ($certificateNamePrefix+"P2SChild") -KeySpec Signature `
    -Subject ("CN=$certificateNamePrefix"+"P2SChild") -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $certificate -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") | Out-null

$publicRootCertData = [Convert]::ToBase64String((Get-Item cert:\currentuser\my\$certificateThumbprint).RawData)

$parameters['publicRootCertData'] = $publicRootCertData

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist.";
    Write-Host "Creating resource group '$resourceGroupName' in location '$location'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location | Out-null
}
else
{
    Write-Host "Using existing resource group '$resourceGroupName'";
}


# Start the deployment
Write-Host "Starting deployment...";

New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri ($scriptUrlBase+'/azuredeploy.json') -TemplateParameterObject $parameters