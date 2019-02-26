param(
[Parameter(Mandatory=$true)]
[PSObject]
$MainTemplateObject
)

$publicIpResources = $MainTemplateObject |
    Find-AzureRMTemplate -Key type -Value 'Microsoft.Network/publicIPAddresses'


foreach ($pir in $publicIpResources) {
    if ($pir.properties.dnsSettings.domainNameLabel -like '*Concat(*') {
        Write-Error "Public IP Resources should not use the Concatenate expression" -TargetObject $pir
    }
}