[CmdletBinding()]
param (
    # Enter resourcegroup name
    [Parameter(Mandatory = $false)]
    [string]
    $ResourceGroupName = "001-VM-Virus-Attack-Prevention",

    # Enter AAD Username password as securestring.
    [Parameter(Mandatory = $false)]
    [string]
    $Location = "eastus"
)

$ErrorActionPreference = 'Stop'

try {
    Write-Verbose "Deleting ResourceGroups"
    Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
}
catch {
    Throw $_
}

Write-Host "Resources deleted successfully."