param(
[Parameter(Mandatory=$true)]
[PSObject]
$MainTemplateObject
)

exit #skipping this test for now

# Find all public IP addresses
$publicIpResources = $MainTemplateObject |
    Find-JsonContent -Key type -Value 'Microsoft.Network/publicIPAddresses'


foreach ($pir in $publicIpResources) {
    if ($pir.properties.dnsSettings.domainNameLabel -like '*Concat(*') { # If the domain name label contains a concat
        Write-Error "Public IP Resources should not use the Concatenate expression" -TargetObject $pir # write an error.
    }
}