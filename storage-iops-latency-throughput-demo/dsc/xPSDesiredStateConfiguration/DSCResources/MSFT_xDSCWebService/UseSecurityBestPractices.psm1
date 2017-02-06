# This module file contains a utility to switch on/off the security best practices
#
# Copyright (c) Microsoft Corporation, 2016
#

Import-Module $PSScriptRoot\SecureTLSProtocols.psm1 -Verbose:$false

# This list corresponds to the ValueMap definition of DisableSecurityBestPractices parameter defined in MSFT_xDSCWebService.Schema.mof
$SecureTLSProtocols = "SecureTLSProtocols";

<#
    .SYNOPSIS
        This function tests whether the node uses security best practices for non-disabled items
#>
function Test-UseSecurityBestPractices
{
    param([string[]] $DisableSecurityBestPractices)

    $usedProtocolsBestPractices = ($DisableSecurityBestPractices -icontains $SecureTLSProtocols) -or (Test-SChannelProtocol)

    return $usedProtocolsBestPractices
}

<#
    .SYNOPSIS
        This function sets the node to use security best practices for non-disabled items
#>
function Set-UseSecurityBestPractices
{
    param([string[]] $DisableSecurityBestPractices)

    if (-not ($DisableSecurityBestPractices -icontains $SecureTLSProtocols))
    {
        Set-SChannelProtocol
    }
}

Export-ModuleMember -function *-UseSecurityBestPractices
