#region JSON Functions
if ($PSVersionTable.PSEdition -ne 'Core') {
    . $psScriptRoot\ConvertFrom-Json.ps1 # Overwriting ConvertFrom-JSON to allow for comments within JSON (not on core)
}

. $psScriptRoot\Import-Json.ps1
. $PSScriptRoot\Find-JsonContent.ps1
#endregion JSON Functions

#region Template Functions
. $PSScriptRoot\Expand-AzTemplate.ps1
. $PSScriptRoot\Test-AzTemplate.ps1

. $PSScriptRoot\Format-AzTemplate.ps1
#endregion Template Functions
Set-Alias Sort-AzTemplate Format-AzTemplate
