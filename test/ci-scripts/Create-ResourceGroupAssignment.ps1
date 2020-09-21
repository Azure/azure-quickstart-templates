<#
    Use this script to create a resourceGroup and assign a principal access to that group
#>

param(
    [string][Parameter(mandatory=$true)] $ResourceGroupName,
    [string][Parameter(mandatory=$true)] $Location,
    [string][Parameter(mandatory=$true)] $appId
)

# Create the group only if it doesn't already exist
if ((Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue) -eq $null) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force
}

# Replication may take a second or two
if ((Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue) -eq $null) {
    Start-Sleep 10
}

# Note that the service principal assigning the role must have AAD perms to query AD for the objectId
# Owner is used on the ResourceGroup in order to delegate permissions to that group
New-AzRoleAssignment -ObjectId $(Get-AzADServicePrincipal -ApplicationId $appId).Id -RoleDefinitionName Owner -ResourceGroupName $ResourceGroupName -Verbose
