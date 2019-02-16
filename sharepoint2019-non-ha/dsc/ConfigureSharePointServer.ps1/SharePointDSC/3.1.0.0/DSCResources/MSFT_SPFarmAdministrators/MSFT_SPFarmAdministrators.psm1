function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Farm Administrators configuration"

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        throw ("Cannot use the Members parameter together with the " + `
               "MembersToInclude or MembersToExclude parameters")
    }

    if (!$Members -and !$MembersToInclude -and !$MembersToExclude)
    {
        throw ("At least one of the following parameters must be specified: " + `
               "Members, MembersToInclude, MembersToExclude")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $webApps = Get-SPwebapplication -IncludeCentralAdministration
        $caWebapp = $webApps | Where-Object -FilterScript {
            $_.IsAdministrationWebApplication
        }

        if ($null -eq $caWebapp)
        {
            Write-Verbose "Unable to locate central administration website"
            return $null
        }
        $caWeb = Get-SPweb($caWebapp.Url)
        $farmAdminGroup = $caWeb.AssociatedOwnerGroup
        $farmAdministratorsGroup = $caWeb.SiteGroups.GetByName($farmAdminGroup)
        return @{
            IsSingleInstance = "Yes"
            Members = $farmAdministratorsGroup.users.UserLogin
            MembersToInclude = $params.MembersToInclude
            MembersToExclude = $params.MembersToExclude
            InstallAccount = $params.InstallAccount
        }
    }
    return $result
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Farm Administrators configuration"

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        throw ("Cannot use the Members parameter together with the " + `
               "MembersToInclude or MembersToExclude parameters")
    }

    if (!$Members -and !$MembersToInclude -and !$MembersToExclude)
    {
        throw ("At least one of the following parameters must be specified: " + `
               "Members, MembersToInclude, MembersToExclude")
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters
    if ($null -eq $CurrentValues)
    {
        throw "Unable to locate central administration website"
    }

    $changeUsers = @{}
    $runChange = $false

    if ($Members)
    {
        Write-Verbose "Processing Members parameter"

        $differences = Compare-Object -ReferenceObject $CurrentValues.Members `
                                      -DifferenceObject $Members

        if ($null -eq $differences)
        {
            Write-Verbose "Farm Administrators group matches. No further processing required"
        }
        else
        {
            Write-Verbose "Farm Administrators group does not match. Perform corrective action"
            $addUsers = @()
            $removeUsers = @()
            foreach ($difference in $differences)
            {
                if ($difference.SideIndicator -eq "=>")
                {
                    # Add account
                    $user = $difference.InputObject
                    Write-Verbose "Add $user to Add list"
                    $addUsers += $user
                }
                elseif ($difference.SideIndicator -eq "<=")
                {
                    # Remove account
                    $user = $difference.InputObject
                    Write-Verbose "Add $user to Remove list"
                    $removeUsers += $user
                }
            }

            if($addUsers.count -gt 0)
            {
                Write-Verbose "Adding $($addUsers.Count) users to the Farm Administrators group"
                $changeUsers.Add = $addUsers
                $runChange = $true
            }

            if($removeUsers.count -gt 0)
            {
                Write-Verbose "Removing $($removeUsers.Count) users from the Farm Administrators group"
                $changeUsers.Remove = $removeUsers
                $runChange = $true
            }
        }
    }

    if ($MembersToInclude)
    {
        Write-Verbose "Processing MembersToInclude parameter"

        $addUsers = @()
        foreach ($member in $MembersToInclude)
        {
            if (-not($CurrentValues.Members -contains $member))
            {
                Write-Verbose "$member is not a Farm Administrator. Add user to Add list"
                $addUsers += $member
            }
            else
            {
                Write-Verbose "$member is already a Farm Administrator. Skipping"
            }
        }

        if($addUsers.count -gt 0)
        {
            Write-Verbose "Adding $($addUsers.Count) users to the Farm Administrators group"
            $changeUsers.Add = $addUsers
            $runChange = $true
        }
    }

    if ($MembersToExclude)
    {
        Write-Verbose "Processing MembersToExclude parameter"

        $removeUsers = @()
        foreach ($member in $MembersToExclude)
        {
            if ($CurrentValues.Members -contains $member)
            {
                Write-Verbose "$member is a Farm Administrator. Add user to Remove list"
                $removeUsers += $member
            }
            else
            {
                Write-Verbose "$member is not a Farm Administrator. Skipping"
            }
        }

        if($removeUsers.count -gt 0)
        {
            Write-Verbose "Removing $($removeUsers.Count) users from the Farm Administrators group"
            $changeUsers.Remove = $removeUsers
            $runChange = $true
        }
    }

    if ($runChange)
    {
        Write-Verbose "Apply changes"
        Merge-SPDscFarmAdminList $changeUsers
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [System.String[]]
        $Members,

        [Parameter()]
        [System.String[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Farm Administrators configuration"

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        throw ("Cannot use the Members parameter together with the " + `
               "MembersToInclude or MembersToExclude parameters")
    }

    if (!$Members -and !$MembersToInclude -and !$MembersToExclude)
    {
        throw ("At least one of the following parameters must be specified: " + `
               "Members, MembersToInclude, MembersToExclude")
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }

    if ($Members)
    {
        Write-Verbose "Processing Members parameter"
        $differences = Compare-Object -ReferenceObject $CurrentValues.Members `
                                      -DifferenceObject $Members

        if ($null -eq $differences)
        {
            Write-Verbose "Farm Administrators group matches"
            return $true
        }
        else
        {
            Write-Verbose "Farm Administrators group does not match"
            return $false
        }
    }

    $result = $true
    if ($MembersToInclude)
    {
        Write-Verbose "Processing MembersToInclude parameter"
        foreach ($member in $MembersToInclude)
        {
            if (-not($CurrentValues.Members -contains $member))
            {
                Write-Verbose "$member is not a Farm Administrator. Set result to false"
                $result = $false
            }
            else
            {
                Write-Verbose "$member is already a Farm Administrator. Skipping"
            }
        }
    }

    if ($MembersToExclude)
    {
        Write-Verbose "Processing MembersToExclude parameter"
        foreach ($member in $MembersToExclude)
        {
            if ($CurrentValues.Members -contains $member)
            {
                Write-Verbose "$member is a Farm Administrator. Set result to false"
                $result = $false
            }
            else
            {
                Write-Verbose "$member is not a Farm Administrator. Skipping"
            }
        }
    }

    return $result
}

function Merge-SPDscFarmAdminList
{
    param (
        [Parameter()]
        [Hashtable]
        $changeUsers
    )

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $changeUsers -ScriptBlock {
        $changeUsers = $args[0]

        $webApps = Get-SPwebapplication -IncludeCentralAdministration
        $caWebapp = $webApps | Where-Object -FilterScript {
            $_.IsAdministrationWebApplication
        }
        if ($null -eq $caWebapp)
        {
            throw "Unable to locate central administration website"
        }
        $caWeb = Get-SPweb($caWebapp.Url)
        $farmAdminGroup = $caWeb.AssociatedOwnerGroup

        if ($changeUsers.ContainsKey("Add"))
        {
            foreach ($loginName in $changeUsers.Add)
            {
                $caWeb.SiteGroups.GetByName($farmAdminGroup).AddUser($loginName,"","","")
            }
        }

        if ($changeUsers.ContainsKey("Remove"))
        {
            foreach ($loginName in $changeUsers.Remove)
            {
                $removeUser = get-spuser $loginName -web $caWebapp.Url
                $caWeb.SiteGroups.GetByName($farmAdminGroup).RemoveUser($removeUser)
            }
        }
    }
}

Export-ModuleMember -Function *-TargetResource
