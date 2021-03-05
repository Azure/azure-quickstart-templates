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
$ra = New-AzRoleAssignment -ObjectId $(Get-AzADServicePrincipal -ApplicationId $appId).Id -RoleDefinitionName Owner -ResourceGroupName $ResourceGroupName -Verbose

# We're seeing failures due to replication, so adding a "sleep" to try to ensure the role has replicated
$path = "$($ra.RoleAssignmentId)?api-version=2020-04-01-preview"
$successCount = 0
while($successCount -lt 5){ # want to see success over n successive GETs on the resource

    $r = Invoke-AzRestMethod -Method "GET" -Path $path #REST is much lighter weight than the PS cmdlet
    Write-Host "RoleAssignment GET returned status code: $($r.StatusCode)"
    if($r.StatusCode -eq "200"){
        $successCount ++
    }else{
        $successCount = 0
        Write-Warning "DEBUG: Check to see if the GET ever returns 404"
    }
    Start-Sleep 5
}
