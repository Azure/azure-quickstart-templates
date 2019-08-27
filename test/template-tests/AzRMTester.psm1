if ($PSVersionTable.PSEdition -ne 'Core') {
    . $psScriptRoot\ConvertFrom-Json.ps1 # Overwriting ConvertFrom-JSON to allow for comments within JSON (not on core)
}
. $PSScriptRoot\Find-JsonContent.ps1


. $PSScriptRoot\Expand-AzureRMTemplate.ps1
. $PSScriptRoot\Test-AzureRMTemplate.ps1

. $PSScriptRoot\Format-AzureRMTemplate.ps1

Set-Alias Sort-AzureRMTemplate Format-AzureRMTemplate
