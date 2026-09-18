<#
.SYNOPSIS
Stops an Azure Database for PostgreSQL Flexible Server when it is running.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $SubscriptionId,

    [Parameter(Mandatory)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory)]
    [string] $ServerName
)

$ErrorActionPreference = 'Stop'

try {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity | Out-Null
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

    $server = Get-AzPostgreSqlFlexibleServer `
        -SubscriptionId $SubscriptionId `
        -ResourceGroupName $ResourceGroupName `
        -Name $ServerName

    if ($server.State -eq 'Ready') {
        Write-Output "Stopping PostgreSQL Flexible Server '$ServerName'."
        Stop-AzPostgreSqlFlexibleServer `
            -SubscriptionId $SubscriptionId `
            -ResourceGroupName $ResourceGroupName `
            -Name $ServerName | Out-Null
        Write-Output "Stop request submitted for '$ServerName'."
    }
    else {
        Write-Output "No action: '$ServerName' is in state '$($server.State)'."
    }
}
catch {
    Write-Error "Unable to evaluate or stop PostgreSQL Flexible Server '$ServerName': $($_.Exception.Message)"
    throw
}
