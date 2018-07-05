[CmdletBinding()]
param (
    # Enter resourcegroup name
    [Parameter(Mandatory = $false)]
    [string]
    $ResourceGropuName = "001-VM-Virus-Attack-Prevention",

    # Enter AAD Username password as securestring.
    [Parameter(Mandatory = $false)]
    [string]
    $Location = "eastus"
)

$ErrorActionPreference = 'Stop'

try {
    Write-Verbose "Deleting ResourceGroups"
    Remove-AzureRmResourceGroup -Name $ResourceGropuName -Force
}
catch {
    Throw $_
}

Write-Host "Resources deleted successfully."