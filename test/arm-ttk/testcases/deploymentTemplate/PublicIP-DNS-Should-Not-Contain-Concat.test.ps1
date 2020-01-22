<#
param(
[Parameter(Mandatory=$true)]
[PSObject]
$MainTemplateObject
)
#>

Write-Warning "Skipping DNS test, see code comments..."
exit 

<# 

skipping this test for now, the test is too restrictive, it needs to account for:
- unique seeds being used as part of the concat() e.g.  concat('base', uniqueString(resourceGroup(),id), copyIndex())
- a param or var might contain that unique seed, the the template needs to be expanded
- if we're testing a single file, $MainTemplateObject may be null
- concat() regex needs to account for whitespace (check other tests for this)

#>


# Find all public IP addresses
$publicIpResources = $MainTemplateObject |
    Find-JsonContent -Key type -Value 'Microsoft.Network/publicIPAddresses'


foreach ($pir in $publicIpResources) {
    if ($pir.properties.dnsSettings.domainNameLabel -like '*Concat(*') { # If the domain name label contains a concat
        Write-Error "Public IP Resources should not use the Concatenate expression" -TargetObject $pir # write an error.
    }
}