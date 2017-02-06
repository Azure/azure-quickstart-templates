$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

#Import CommonResourceHelper for Test-IsNanoServer
$moduleRootFilePath = Split-Path -Path $PSScriptRoot -Parent
$dscResourcesFolderFilePath = Join-Path -Path $moduleRootFilePath -ChildPath 'DSCResources'
$commonResourceHelperFilePath = Join-Path -Path $dscResourcesFolderFilePath -ChildPath 'CommonResourceHelper.psm1'
Import-Module -Name $commonResourceHelperFilePath

<#
    .SYNOPSIS
        Tests if a Windows group with the given name and members exists.

    .PARAMETER GroupName
        The name of the group.

    .PARAMETER Members
        The usernames of the members of the group.

    .PARAMETER MembersToInclude
        The usernames of the members that should be included in the group.

    .PARAMETER MembersToExclude
        The usernames of the members that should be excluded from the group.
#>
function Test-GroupExists
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $GroupName,

        [Parameter()]
        [String[]]
        $Members,

        [Parameter()]
        [String[]]
        $MembersToInclude,

        [Parameter()]
        [String[]]
        $MembersToExclude
    )

    if (Test-IsNanoServer)
    {
        return Test-GroupExistsOnNanoServer @PSBoundParameters
    }
    else
    {
        return Test-GroupExistsOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Tests if a Windows group with the given name and members exists.

    .PARAMETER GroupName
        The name of the group.

    .PARAMETER Members
        The usernames of the members of the group.

    .PARAMETER MembersToInclude
        The usernames of the members that should be included in the group.

    .PARAMETER MembersToExclude
        The usernames of the members that should be excluded from the group.
#>
function Test-GroupExistsOnFullSKU
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [Parameter()]
        [String[]]
        $Members,

        [Parameter()]
        [String[]]
        $MembersToInclude,

        [Parameter()]
        [String[]]
        $MembersToExclude
    )

    $principalContext = New-Object -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext' `
        -ArgumentList @( [System.DirectoryServices.AccountManagement.ContextType]::Machine )

    $group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($principalContext, $GroupName)
    $groupExists = $null -ne $group

    if ($groupExists)
    {
        if ($PSBoundParameters.ContainsKey('Members'))
        {
            $noActualMembers = ($null -eq $group.Members) -or ($group.Members.Count -eq 0)
            $noExpectedMembers = ($null -eq $Members) -or ($Members.Count -eq 0)

            if ($noActualMembers -and $noExpectedMembers)
            {
                $membersMatch = $true
            }
            elseif ($noActualMembers -xor $noExpectedMembers)
            {
                $membersMatch = $false
            }
            else
            {
                $membersMatch = $null -eq (Compare-Object -ReferenceObject $Members -DifferenceObject $group.Members.Name)
            }

            $groupExists = $groupExists -and $membersMatch
        }

        if ($PSBoundParameters.ContainsKey('MembersToInclude'))
        {
            $noActualMembers = ($null -eq $group.Members) -or ($group.Members.Count -eq 0)
            $noExpectedMembers = ($null -eq $MembersToInclude) -or ($MembersToInclude.Count -eq 0)

            if ($noExpectedMembers)
            {
                $membersToIncludeMatch = $true
            }
            elseif ($noActualMembers)
            {
                $membersToIncludeMatch = $false
            }
            else
            {
                $membersToIncludeMatch = $true

                foreach ($expectedMemberName in $MembersToInclude)
                {
                    if ($group.Members.Name -inotcontains $expectedMemberName)
                    {
                        $membersToIncludeMatch = $false
                        break
                    }
                }
            }

            $groupExists = $groupExists -and $membersToIncludeMatch
        }

        if ($PSBoundParameters.ContainsKey('MembersToExclude'))
        {
            $noActualMembers = ($null -eq $group.Members) -or ($group.Members.Count -eq 0)
            $noExcludedMembers = ($null -eq $MembersToExclude) -or ($MembersToExclude.Count -eq 0)

            if ($noExcludedMembers)
            {
                $membersToExcludeMatch = $true
            }
            elseif ($noActualMembers)
            {
                $membersToExcludeMatch = $true
            }
            else
            {
                $groupMemberNames = $group.Members.Name | ForEach-Object { ($_ -split '/')[-1] }

                $membersToExcludeMatch = $true

                foreach ($excludedMemberName in $MembersToExclude)
                {
                    if ($group.Members.Name -icontains $excludedMemberName)
                    {
                        $membersToExcludeMatch = $false
                        break
                    }
                }
            }

            $groupExists = $groupExists -and $membersToExcludeMatch
        }
    }

    $null = $principalContext.Dispose()

    return $groupExists
}

<#
    .SYNOPSIS
        Tests if a Windows group with the given name and members exists.

    .PARAMETER GroupName
        The name of the group.

    .PARAMETER Members
        The usernames of the members of the group.

    .PARAMETER MembersToInclude
        The usernames of the members that should be included in the group.

    .PARAMETER MembersToExclude
        The usernames of the members that should be excluded from the group.
#>
function Test-GroupExistsOnNanoServer
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [Parameter()]
        [String[]]
        $Members,

        [Parameter()]
        [String[]]
        $MembersToInclude,

        [Parameter()]
        [String[]]
        $MembersToExclude
    )

    $groupExists = $true

    try
    {
        $null = Get-LocalGroup -Name $GroupName
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.ToString().Contains('GroupNotFoundException'))
        {
            $groupExists = $false
        }
        else
        {
            throw $_.Exception
        }
    }

    if ($groupExists)
    {
        if ($PSBoundParameters.ContainsKey('Members'))
        {
            $groupMembers = Get-LocalGroupMember -Group $Group

            $noActualMembers = ($null -eq $groupMembers) -or ($groupMembers.Count -eq 0)
            $noExpectedMembers = ($null -eq $Members) -or ($Members.Count -eq 0)

            if ($noActualMembers -and $noExpectedMembers)
            {
                $membersMatch = $true
            }
            elseif ($noActualMembers -xor $noExpectedMembers)
            {
                $membersMatch = $false
            }
            else
            {
                $groupMemberNames = $groupMembers.Name | ForEach-Object { ($_ -split '/')[-1] }
                $membersMatch = $null -eq (Compare-Object -ReferenceObject $Members -DifferenceObject $groupMemberNames)
            }

            $groupExists = $groupExists -and $membersMatch
        }

        if ($PSBoundParameters.ContainsKey('MembersToInclude'))
        {
            $groupMembers = Get-LocalGroupMember -Group $Group

            $noActualMembers = ($null -eq $groupMembers) -or ($groupMembers.Count -eq 0)
            $noExpectedMembers = ($null -eq $MembersToInclude) -or ($MembersToInclude.Count -eq 0)

            if ($noExpectedMembers)
            {
                $membersToIncludeMatch = $true
            }
            elseif ($noActualMembers)
            {
                $membersToIncludeMatch = $false
            }
            else
            {
                $groupMemberNames = $groupMembers.Name | ForEach-Object { ($_ -split '/')[-1] }

                $membersToIncludeMatch = $true

                foreach ($expectedMemberName in $MembersToInclude)
                {
                    if ($groupMemberNames -inotcontains $expectedMemberName)
                    {
                        $membersToIncludeMatch = $false
                        break
                    }
                }
            }

            $groupExists = $groupExists -and $membersToIncludeMatch
        }

        if ($PSBoundParameters.ContainsKey('MembersToExclude'))
        {
            $groupMembers = Get-LocalGroupMember -Group $Group

            $noActualMembers = ($null -eq $groupMembers) -or ($groupMembers.Count -eq 0)
            $noExcludedMembers = ($null -eq $MembersToExclude) -or ($MembersToExclude.Count -eq 0)

            if ($noExcludedMembers)
            {
                $membersToExcludeMatch = $true
            }
            elseif ($noActualMembers)
            {
                $membersToExcludeMatch = $true
            }
            else
            {
                $groupMemberNames = $groupMembers.Name | ForEach-Object { ($_ -split '/')[-1] }

                $membersToExcludeMatch = $true

                foreach ($excludedMemberName in $MembersToExclude)
                {
                    if ($groupMemberNames -icontains $excludedMemberName)
                    {
                        $membersToExcludeMatch = $false
                        break
                    }
                }
            }

            $groupExists = $groupExists -and $membersToExcludeMatch
        }
    }

    return $groupExists
}

<#
    .SYNOPSIS
        Creates a Windows group.

    .PARAMETER GroupName
        The name of the group.

    .PARAMETER Description
        The description of the group.

    .PARAMETER Members
        The usernames of the members to add to the group.
#>
function New-Group
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [Parameter()]
        [String]
        $Description,

        [Parameter()]
        [String[]]
        $Members
    )

    if (Test-GroupExists -GroupName $GroupName)
    {
        throw "Group $GroupName already exists."
    }

    if (Test-IsNanoServer)
    {
        New-GroupOnNanoServer @PSBoundParameters
    }
    else
    {
        New-GroupOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Creates a Windows group on a full server.

    .PARAMETER GroupName
        The name of the group.

    .PARAMETER Description
        The description of the group.

    .PARAMETER Members
        The usernames of the members to add to the group.
#>
function New-GroupOnFullSKU
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [Parameter()]
        [String]
        $Description,

        [Parameter()]
        [String[]]
        $Members
    )

    $adsiComputerEntry = [ADSI] "WinNT://$env:computerName"
    $adsiGroupEntry = $adsiComputerEntry.Create('Group', $GroupName)

    if ($PSBoundParameters.ContainsKey('Description'))
    {
        $null = $adsiGroupEntry.Put('Description', $Description)
    }

    $null = $adsiGroupEntry.SetInfo()

    if ($PSBoundParameters.ContainsKey("Members"))
    {
        $adsiGroupEntry = [ADSI]"WinNT://$env:computerName/$GroupName,group"

        foreach ($memberUserName in $Members)
        {
            $null = $adsiGroupEntry.Add("WinNT://$env:computerName/$memberUserName")
        }
    }
}

<#
    .SYNOPSIS
        Creates a Windows group on a Nano server.

    .PARAMETER GroupName
        The name of the group.

    .PARAMETER Description
        The description of the group.

    .PARAMETER Members
        The usernames of the members to add to the group.
#>
function New-GroupOnNanoServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [Parameter()]
        [String]
        $Description,

        [Parameter()]
        [String[]]
        $Members
    )

    $null = New-LocalGroup -Name $GroupName

    if ($PSBoundParameters.ContainsKey('Description'))
    {
        $null = Set-LocalGroup -Name $GroupName -Description $Description
    }

    if ($PSBoundParameters.ContainsKey('Members'))
    {
        $null = Add-LocalGroupMember -Name $GroupName -Member $Members
    }
}

<#
    .SYNOPSIS
        Deletes a Windows group.

    .PARAMETER GroupName
        The name of the group.
#>
function Remove-Group
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName
    )

    if (-not (Test-GroupExists -GroupName $GroupName))
    {
        throw "Group $GroupName does not exist to remove."
    }

    if (Test-IsNanoServer)
    {
        Remove-GroupOnNanoServer @PSBoundParameters
    }
    else
    {
        Remove-GroupOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Deletes a Windows group on a full server.

    .PARAMETER GroupName
        The name of the group.
#>
function Remove-GroupOnFullSKU
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName
    )

    $adsiComputerEntry = [ADSI]("WinNT://$env:computerName")
    $null = $adsiComputerEntry.Delete('Group', $GroupName)
}

<#
    .SYNOPSIS
        Deletes a Windows group on a Nano server.

    .PARAMETER GroupName
        The name of the group.
#>
function Remove-GroupOnNanoServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName
    )

    Remove-LocalGroup -Name $GroupName
}

<#
    .SYNOPSIS
        Tests if a user with the given username exists.

    .PARAMETER Username
        The username of the user.
#>
function Test-UserExists
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Username
    )

    if (Test-IsNanoServer)
    {
        return Test-UserExistsOnNanoServer @PSBoundParameters
    }
    else
    {
        return Test-UserExistsOnFullSKU @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Tests if a user with the given username exists on a full server.

    .PARAMETER Username
        The username of the user.
#>
function Test-UserExistsOnFullSKU
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Username
    )

    $principalContext = New-Object -TypeName 'System.DirectoryServices.AccountManagement.PrincipalContext' `
        -ArgumentList @( [System.DirectoryServices.AccountManagement.ContextType]::Machine )

    $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($principalContext, $Username)
    $userExists = $null -ne $user

    $null = $principalContext.Dispose()

    return $userExists
}

<#
    .SYNOPSIS
        Tests if a user with the given username exists on a Nano server.

    .PARAMETER Username
        The username of the user.
#>
function Test-UserExistsOnNanoServer
{
    [OutputType([Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Username
    )

    $userExists = $true

    try
    {
        $null = Get-LocalUser -Name $Username
    }
    catch [System.Exception]
    {
        if ($_.CategoryInfo.ToString().Contains('UserNotFoundException'))
        {
            $userExists = $false
        }
        else
        {
            $_.Exception
        }
    }

    return $userExists
}

<#
    .SYNOPSIS
        Creates a user account.

    .PARAMETER Credential
        The credential containing the user's username and password.
#>
function New-User
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    if (Test-UserExists -Username $Credential.UserName)
    {
        throw "User $($Credential.UserName) already exists."
    }

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
        Creates a user on a full server.

    .PARAMETER Credential
        The credential containing the user's username and password.
#>
function New-UserOnFullSKU
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $userName = $Credential.UserName
    $password = $Credential.GetNetworkCredential().Password

    $adsiComputerEntry = [ADSI]("WinNT://$env:computerName")
    $adsiUserEntry = $adsiComputerEntry.Create('User', $userName)
    $null = $adsiUserEntry.SetPassword($password)
    $null = $adsiUserEntry.SetInfo()
}

<#
    .SYNOPSIS
        Creates a user on a Nano server.

    .PARAMETER Credential
        The credential containing the user's username and password.
#>
function New-UserOnNanoServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $userName = $Credential.UserName
    $securePassword = $Credential.GetNetworkCredential().Password

    New-LocalUser -Name $userName -Password $securePassword
}

<#
    .SYNOPSIS
        Removes a user.

    .PARAMETER UserName
        The name of the user.
#>
function Remove-User
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $UserName
    )

    if (-not (Test-UserExists -Username $Username))
    {
        throw "User $Username does not exist to remove."
    }

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
        Removes a user on a full server.

    .PARAMETER UserName
        The name of the user.
#>
function Remove-UserOnFullSKU
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $UserName
    )

    $adsiComputerEntry = [ADSI]("WinNT://$env:computerName")
    $null = $adsiComputerEntry.Delete('User', $UserName)
}

<#
    .SYNOPSIS
        Removes a user on a Nano server.

    .PARAMETER UserName
        The name of the user.
#>
function Remove-UserOnNanoServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $UserName
    )

    $null = Remove-LocalUser -Name $UserName
}

Export-ModuleMember -Function @( 'New-Group', 'Remove-Group', 'Test-GroupExists', 'New-User', 'Remove-User' )
