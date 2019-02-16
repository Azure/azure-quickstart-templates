function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProxyName,

        [Parameter()]
        [System.String[]]
        $CreatePersonalSite,

        [Parameter()]
        [System.String[]]
        $FollowAndEditProfile,

        [Parameter()]
        [System.String[]]
        $UseTagsAndNotes,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting permissions for user profile service proxy '$ProxyName"

    Confirm-SPDscUpaPermissionsConfig -Parameters $PSBoundParameters

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]

        $proxy = Get-SPServiceApplicationProxy | Where-Object { $_.DisplayName -eq $params.ProxyName }
        if ($null -eq $proxy)
        {
            return @{
                ProxyName = $params.ProxyName
                CreatePersonalSite = $null
                FollowAndEditProfile = $null
                UseTagsAndNotes = $null
                InstallAccount = $params.InstallAccount
            }
        }
        $security = Get-SPProfileServiceApplicationSecurity -ProfileServiceApplicationProxy $proxy

        $createPersonalSite = @()
        $followAndEditProfile = @()
        $useTagsAndNotes = @()

        foreach ($securityEntry in $security.AccessRules)
        {
            $user = $securityEntry.Name
            if ($user -like "i:*|*" -or $user -like "c:*|*")
            {
                # Only claims users can be processed by the PowerShell cmdlets, so only
                # report on and manage the claims identities
                if ($user -eq "c:0(.s|true")
                {
                    $user = "Everyone"
                }
                else
                {
                    $user = (New-SPClaimsPrincipal -Identity $user -IdentityType EncodedClaim).Value
                }
            }
            if ($securityEntry.AllowedRights.ToString() -eq "All")
            {
                $createPersonalSite += $user
                $followAndEditProfile += $user
                $useTagsAndNotes += $user
            }
            if ($securityEntry.AllowedRights.ToString() -like "*UsePersonalFeatures*")
            {
                $followAndEditProfile += $user
            }
            if ($securityEntry.AllowedRights.ToString() -like "*UseSocialFeatures*")
            {
                $useTagsAndNotes += $user
            }
            if (($securityEntry.AllowedRights.ToString() -like "*CreatePersonalSite*") `
                -and ($securityEntry.AllowedRights.ToString() -like "*UseMicrobloggingAndFollowing*"))
            {
                $createPersonalSite += $user
            }
        }

        if (!$createPersonalSite)
        {
            $createPersonalSite += "None"
        }
        if (!$followAndEditProfile)
        {
            $followAndEditProfile += "None"
        }
        if (!$useTagsAndNotes)
        {
            $useTagsAndNotes += "None"
        }

        return @{
            ProxyName = $params.ProxyName
            CreatePersonalSite = $createPersonalSite
            FollowAndEditProfile = $followAndEditProfile
            UseTagsAndNotes = $useTagsAndNotes
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
        [System.String]
        $ProxyName,

        [Parameter()]
        [System.String[]]
        $CreatePersonalSite,

        [Parameter()]
        [System.String[]]
        $FollowAndEditProfile,

        [Parameter()]
        [System.String[]]
        $UseTagsAndNotes,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting permissions for user profile service proxy '$ProxyName"

    Confirm-SPDscUpaPermissionsConfig -Parameters $PSBoundParameters

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($CurrentValues.CreatePersonalSite -contains "NT AUTHORITY\Authenticated Users" `
        -or $CurrentValues.FollowAndEditProfile -contains "NT AUTHORITY\Authenticated Users" `
        -or $CurrentValues.UseTagsAndNotes -contains "NT AUTHORITY\Authenticated Users")
    {
        Write-Warning -Message ("Permissions were found for the non-claims identity " + `
                                "'NT AUTHORITY\Authenticated Users'. This will be removed as " + `
                                "identies on service app proxy permissions should be claims based.")

        Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0]

            $proxy = Get-SPServiceApplicationProxy | Where-Object { $_.DisplayName -eq $params.ProxyName }
            $security = Get-SPProfileServiceApplicationSecurity -ProfileServiceApplicationProxy $proxy
            Revoke-SPObjectSecurity -Identity $security -All
            Set-SPProfileServiceApplicationSecurity -Identity $security -ProfileServiceApplicationProxy $proxy -Confirm:$false
            Write-Verbose -Message "Successfully cleared all permissions on the service app proxy"
        }

        Write-Verbose -Message "Waiting 2 minutes for proxy permissions to be applied fully before continuing"
        Start-Sleep -Seconds 120
        Write-Verbose -Message "Continuing configuration by getting the new current values."
        $CurrentValues = Get-TargetResource @PSBoundParameters
    }

    Invoke-SPDSCCommand -Credential $InstallAccount -Arguments @($PSBoundParameters, $CurrentValues) -ScriptBlock {
        $params = $args[0]
        $CurrentValues = $args[1]

        $proxy = Get-SPServiceApplicationProxy | Where-Object { $_.DisplayName -eq $params.ProxyName }
        if ($null -eq $proxy)
        {
            throw "Unable to find service application proxy called '$($params.ProxyName)'"
            return
        }
        $security = Get-SPProfileServiceApplicationSecurity -ProfileServiceApplicationProxy $proxy

        $permissionsToUpdate = @{
            "CreatePersonalSite" = "Create Personal Site"
            "FollowAndEditProfile" = "Use Personal Features"
            "UseTagsAndNotes" = "Use Social Features"
        }

        foreach ($permission in $permissionsToUpdate.Keys)
        {
            $permissionsDiff = Compare-Object -ReferenceObject $CurrentValues.$permission `
                                              -DifferenceObject  $params.$permission

            $everyoneDiff = $permissionsDiff | Where-Object -FilterScript { $_.InputObject -eq "Everyone" }
            $noneDiff = $permissionsDiff | Where-Object -FilterScript { $_.InputObject -eq "None" }

            if (($null -ne $noneDiff) -and ($noneDiff.SideIndicator -eq "=>"))
            {
                # Need to remove everyone
                foreach($user in $CurrentValues.$permission)
                {
                    if ($user -ne "Everyone" -and $user -ne "None" -and $user)
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $user
                        if ($isUser -eq $true)
                        {
                            $claim = New-SPClaimsPrincipal -Identity $user `
                                                           -IdentityType WindowsSamAccountName
                        }
                        else
                        {
                            $claim = New-SPClaimsPrincipal -Identity $user `
                                                           -IdentityType WindowsSecurityGroupName
                        }
                        Revoke-SPObjectSecurity -Identity $security `
                                                -Principal $claim `
                                                -Rights $permissionsToUpdate.$permission
                    }
                    elseif ($user -eq "Everyone")
                    {
                        # Revoke the all user permissions
                        $allClaimsUsersClaim = New-SPClaimsPrincipal -Identity "c:0(.s|true" `
                                                                     -IdentityType EncodedClaim
                        Revoke-SPObjectSecurity -Identity $security `
                                                -Principal $allClaimsUsersClaim `
                                                -Rights $permissionsToUpdate.$permission
                    }
                }
            }
            elseif (($null -ne $everyoneDiff) -and ($everyoneDiff.SideIndicator -eq "=>"))
            {
                # Need to add everyone, so remove all the permissions that exist currently of this type
                # and then add the everyone permissions
                foreach($user in $CurrentValues.$permission)
                {
                    if ($user -ne "Everyone" -and $user -ne "None" -and $user)
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $user
                        if ($isUser -eq $true)
                        {
                            $claim = New-SPClaimsPrincipal -Identity $user `
                                                           -IdentityType WindowsSamAccountName
                        }
                        else
                        {
                            $claim = New-SPClaimsPrincipal -Identity $user `
                                                           -IdentityType WindowsSecurityGroupName
                        }
                        Revoke-SPObjectSecurity -Identity $security `
                                                -Principal $claim `
                                                -Rights $permissionsToUpdate.$permission
                    }
                }

                $allClaimsUsersClaim = New-SPClaimsPrincipal -Identity "c:0(.s|true" `
                                                             -IdentityType EncodedClaim
                Grant-SPObjectSecurity -Identity $security `
                                       -Principal $allClaimsUsersClaim `
                                       -Rights $permissionsToUpdate.$permission
            }
            else
            {
                # permission changes aren't to everyone or none, process each change
                foreach ($permissionChange in $permissionsDiff)
                {
                    if ($permissionChange.InputObject -ne "Everyone" -and `
                        $permissionChange.InputObject -ne "None")
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $permissionChange.InputObject
                        if ($isUser -eq $true)
                        {
                            $claim = New-SPClaimsPrincipal -Identity $permissionChange.InputObject `
                                                           -IdentityType WindowsSamAccountName
                        }
                        else
                        {
                            $claim = New-SPClaimsPrincipal -Identity $permissionChange.InputObject `
                                                           -IdentityType WindowsSecurityGroupName
                        }
                        if ($permissionChange.SideIndicator -eq "=>")
                        {
                            # Grant permission to the identity
                            Grant-SPObjectSecurity -Identity $security `
                                                   -Principal $claim `
                                                   -Rights $permissionsToUpdate.$permission
                        }
                        if ($permissionChange.SideIndicator -eq "<=")
                        {
                            # Revoke permission for the identity
                            Revoke-SPObjectSecurity -Identity $security `
                                                    -Principal $claim `
                                                    -Rights $permissionsToUpdate.$permission
                        }
                    }
                }
            }
        }

        Set-SPProfileServiceApplicationSecurity -Identity $security `
                                                -ProfileServiceApplicationProxy $proxy `
                                                -Confirm:$false
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProxyName,

        [Parameter()]
        [System.String[]]
        $CreatePersonalSite,

        [Parameter()]
        [System.String[]]
        $FollowAndEditProfile,

        [Parameter()]
        [System.String[]]
        $UseTagsAndNotes,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing permissions for user profile service proxy '$ProxyName"

    Confirm-SPDscUpaPermissionsConfig -Parameters $PSBoundParameters

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("CreatePersonalSite", `
                                                         "FollowAndEditProfile", `
                                                         "UseTagsAndNotes")
}

function Confirm-SPDscUpaPermissionsConfig()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Object]
        $Parameters
    )

    @(
        "CreatePersonalSite",
        "FollowAndEditProfile",
        "UseTagsAndNotes"
    ) | ForEach-Object -Process {
        if (($Parameters.$_ -contains "Everyone") -and ($Parameters.$_ -contains "None"))
        {
            throw ("You can not specify 'Everyone' and 'None' in the same property. " + `
                   "Check the value for the '$_' property on this resource.")
        }
    }
}

Export-ModuleMember -Function *-TargetResource
