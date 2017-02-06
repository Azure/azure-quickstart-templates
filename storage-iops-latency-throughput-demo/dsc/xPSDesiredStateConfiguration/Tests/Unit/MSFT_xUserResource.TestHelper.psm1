Import-Module "$PSScriptRoot\..\..\DSCResources\CommonResourceHelper.psm1" -Force

<#
    .SYNOPSIS
        Tests if a scope represents the current machine.

    .PARAMETER Scope
        The scope to test.
#>
function Test-IsLocalMachine
{
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Scope
    )

    Set-StrictMode -Version latest

    if ($scope -eq '.')
    {
        return $true
    }

    if ($scope -eq $env:COMPUTERNAME)
    {
        return $true
    }

    if ($scope -eq 'localhost')
    {
        return $true
    }

    if ($scope.Contains('.'))
    {
        if ($scope -eq '127.0.0.1')
        {
            return $true
        }

        # Determine if we have an ip address that matches an ip address on one of the network adapters.
        # NOTE: This is likely overkill; consider removing it.
        $networkAdapters = @(Get-CimInstance Win32_NetworkAdapterConfiguration)
        foreach ($networkAdapter in $networkAdapters)
        {
            if ($null -ne $networkAdapter.IPAddress)
            {
                foreach ($address in $networkAdapter.IPAddress)
                {
                    if ($address -eq $scope)
                    {
                        return $true
                    }
                }
            }
        }
    }

    return $false
}

<#
    .SYNOPSIS
        Creates a user account.

    .DESCRIPTION
        This function creates a user on the local or remote machine.

    .PARAMETER Credential
        The credential containing the username and password to use to create the account.

    .PARAMETER Description
        The optional description to set on the user account.

    .PARAMETER ComputerName
        The optional name of the computer to update. Omit to create a user on the local machine.

    .NOTES
        For remote machines, the currently logged on user must have rights to create a user.
#>
function New-User
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.String]
        $Description,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    if (Test-IsNanoServer)
    {
        New-UserOnNanoServer @PSBoundParameters
    }
    else
    {
        New-UserOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Creates a user account on a full server.

    .DESCRIPTION
        This function creates a user on the local or remote machine running a full server.

    .PARAMETER Credential
        The credential containing the username and password to use to create the account.

    .PARAMETER Description
        The optional description to set on the user account.

    .PARAMETER ComputerName
        The optional name of the computer to update. Omit to create a user on the local machine.

    .NOTES
        For remote machines, the currently logged on user must have rights to create a user.
#>
function New-UserOnFullSKU
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.String]
        $Description,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    Set-StrictMode -Version Latest

    $userName = $Credential.UserName
    $password = $Credential.GetNetworkCredential().Password

    # Remove user if it already exists.
    Remove-User $userName $ComputerName

    $adComputerEntry = [ADSI] "WinNT://$ComputerName"
    $adUserEntry = $adComputerEntry.Create('User', $userName)
    $null = $adUserEntry.SetPassword($password)

    if ($PSBoundParameters.ContainsKey('Description'))
    {
        $null = $adUserEntry.Put('Description', $Description)
    }

    $null = $adUserEntry.SetInfo()
}

<#
    .SYNOPSIS
        Creates a user account on a Nano server.

    .DESCRIPTION
        This function creates a user on the local machine running a Nano server.

    .PARAMETER Credential
        The credential containing the username and password to use to create the account.

    .PARAMETER Description
        The optional description to set on the user account.

    .PARAMETER ComputerName
        This parameter should not be used on NanoServer.
#>
function New-UserOnNanoServer
{

    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [System.String]
        $Description,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    Set-StrictMode -Version Latest

    if ($PSBoundParameters.ContainsKey('ComputerName'))
    {
        if (-not (Test-IsLocalMachine -Scope $ComputerName))
        {
            throw 'Do not specify the ComputerName arguments when running on NanoServer unless it is local machine.'
        }
    }

    $userName = $Credential.UserName
    $securePassword = $Credential.GetNetworkCredential().SecurePassword

    # Remove user if it already exists.
    Remove-LocalUser -Name $userName -ErrorAction SilentlyContinue

    New-LocalUser -Name $userName -Password $securePassword

    if ($PSBoundParameters.ContainsKey('Description'))
    {
        Set-LocalUser -Name $userName -Description $Description
    }
}

<#
    .SYNOPSIS
        Removes a user account.

    .DESCRIPTION
        This function removes a local user from the local or remote machine.

    .PARAMETER UserName
        The name of the user to remove.

    .PARAMETER ComputerName
        The optional name of the computer to update. Omit to remove the user on the local machine.

    .NOTES
        For remote machines, the currently logged on user must have rights to remove a user.
#>
function Remove-User
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    if (Test-IsNanoServer)
    {
        Remove-UserOnNanoServer @PSBoundParameters
    }
    else
    {
        Remove-UserOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Removes a user account on a full server.

    .DESCRIPTION
        This function removes a local user from the local or remote machine running a full server.

    .PARAMETER UserName
        The name of the user to remove.

    .PARAMETER ComputerName
        The optional name of the computer to update. Omit to remove the user on the local machine.

    .NOTES
        For remote machines, the currently logged on user must have rights to remove a user.
#>
function Remove-UserOnFullSKU
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    Set-StrictMode -Version Latest

    $adComputerEntry = [ADSI] "WinNT://$ComputerName"

    if ($adComputerEntry.Children | Where-Object Path -like "WinNT://*$ComputerName/$UserName")
    {
        $null = $adComputerEntry.Delete('user', $UserName)
    }
}

<#
    .SYNOPSIS
        Removes a local user account on a Nano server.

    .DESCRIPTION
        This function removes a local user from the local machine running a Nano Server.

    .PARAMETER UserName
        The name of the user to remove.

    .PARAMETER ComputerName
        This parameter should not be used on NanoServer.
#>
function Remove-UserOnNanoServer
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $UserName,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    Set-StrictMode -Version Latest

    if ($PSBoundParameters.ContainsKey('ComputerName'))
    {
        if (-not (Test-IsLocalMachine -Scope $ComputerName))
        {
            throw 'Do not specify the ComputerName arguments when running on NanoServer unless it is local machine.'
        }
    }

    Remove-LocalUser -Name $UserName
}

<#
    .SYNOPSIS
        Determines if a user exists..

    .DESCRIPTION
        This function determines if a user exists on a local or remote machine running.

    .PARAMETER UserName
        The name of the user to test.

    .PARAMETER ComputerName
        The optional name of the computer to update.
#>
function Test-User
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    if (Test-IsNanoServer)
    {
        Test-UserOnNanoServer @PSBoundParameters
    }
    else
    {
        Test-UserOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Determines if a user exists on a full server.

    .DESCRIPTION
        This function determines if a user exists on a local or remote machine running a full server.

    .PARAMETER UserName
        The name of the user to test.

    .PARAMETER ComputerName
        The optional name of the computer to update.
#>
function Test-UserOnFullSKU
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    Set-StrictMode -Version Latest

    $adComputerEntry = [ADSI] "WinNT://$ComputerName"
    if ($adComputerEntry.Children | Where-Object Path -like "WinNT://*$ComputerName/$UserName")
    {
        return $true
    }

    return $false
}

<#
    .SYNOPSIS
        Determines if a user exists on a Nano server.

    .DESCRIPTION
        This function determines if a user exists on a local or remote machine running a Nano server.

    .PARAMETER UserName
        The name of the user to test.

    .PARAMETER ComputerName
        This parameter should not be used on NanoServer.
#>
function Test-UserOnNanoServer
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserName,

        [System.String]
        $ComputerName = $env:COMPUTERNAME
    )

    if ($PSBoundParameters.ContainsKey('ComputerName'))
    {
        if (-not (Test-IsLocalMachine -Scope $ComputerName))
        {
            throw 'Do not specify the ComputerName arguments when running on NanoServer unless it is local machine.'
        }
    }

    # Try to find a group by its name.
    try
    {
        $null = Get-LocalUser -Name $UserName -ErrorAction Stop
        return $true
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.ToString().Contains('UserNotFoundException'))
        {
            # A user with the provided name does not exist.
            return $false
        }
        throw $_.Exception
    }
    finally
    {
        Remove-LocalUser -Name $UserName
    }

    return $false
}

Export-ModuleMember -Function `
    New-User, `
    Remove-User, `
    Test-IsLocalMachine, `
    Test-User
