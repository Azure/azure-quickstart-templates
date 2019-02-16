function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $WebAppUrl,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Members,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $MembersToInclude,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $MembersToExclude,

        [Parameter()] 
        [System.Boolean] 
        $SetCacheAccountsPolicy,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting web app policy for $WebAppUrl"

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        Write-Verbose -Message ("Cannot use the Members parameter together with " + `
                               "the MembersToInclude or MembersToExclude parameters")
        return $null
    }

    if (!$Members -and !$MembersToInclude -and !$MembersToExclude)
    {
        Write-Verbose -Message ("At least one of the following parameters must be specified: " + `
                               "Members, MembersToInclude, MembersToExclude")
        return $null
    }

    foreach ($member in $Members)
    {
        if (($member.ActAsSystemAccount -eq $true) `
            -and ($member.PermissionLevel -ne "Full Control"))
        {
            Write-Verbose -Message ("Members Parameter: You cannot specify ActAsSystemAccount " + `
                                   "with any other permission than Full Control")
            return $null
        }
    }

    foreach ($member in $MembersToInclude)
    {
        if (($member.ActAsSystemAccount -eq $true) `
            -and ($member.PermissionLevel -ne "Full Control"))
        {
            Write-Verbose -Message ("MembersToInclude Parameter: You cannot specify " + `
                                    "ActAsSystemAccount with any other permission than Full " + `
                                    "Control")
            return $null
        }
    }
    
    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl `
                                   -ErrorAction SilentlyContinue

        if ($null -eq $wa)
        {
            return $null 
        }

        $SetCacheAccountsPolicy = $false
        if ($params.SetCacheAccountsPolicy)
        {
            if (($wa.Properties.ContainsKey("portalsuperuseraccount") -eq $true) -and `
                ($wa.Properties.ContainsKey("portalsuperreaderaccount") -eq $true))
                {

                $correctPSU = $false
                $correctPSR = $false

                $psu = $wa.Policies[$wa.Properties["portalsuperuseraccount"]]
                if ($null -ne $psu)
                {
                    if ($psu.PolicyRoleBindings.Type -eq 'FullControl')
                    {
                        $correctPSU = $true 
                    }
                }

                $psr = $wa.Policies[$wa.Properties["portalsuperreaderaccount"]]
                if ($null -ne $psr)
                {
                    if ($psr.PolicyRoleBindings.Type -eq 'FullRead')
                    {
                        $correctPSR = $true 
                    }
                }

                if ($correctPSU -eq $true -and $correctPSR -eq $true)
                {
                    $SetCacheAccountsPolicy = $true
                }
            }
        }
           
        $members = @()
        foreach ($policy in $wa.Policies)
        {
            $member = @{}
            $memberName = $policy.UserName
            $identityType = "Native"
            if ($memberName -like "i:*|*" -or $memberName -like "c:*|*")
            {
                $identityType = "Claims"
                $convertedClaim = New-SPClaimsPrincipal -Identity $memberName `
                                                        -IdentityType EncodedClaim `
                                                        -ErrorAction SilentlyContinue
                if ($null -ne $convertedClaim)
                {
                    $memberName = $convertedClaim.Value
                }
            }

            if ($memberName -match "^s-1-[0-59]-\d+-\d+-\d+-\d+-\d+")
            {
                $memberName = Resolve-SPDscSecurityIdentifier -SID $memberName
            }

            switch ($policy.PolicyRoleBindings.Type)
            {
                'DenyAll'
                {
                    $memberPermissionlevel = 'Deny All'
                }
                'DenyWrite'
                {
                    $memberPermissionlevel = 'Deny Write'
                }
                'FullControl'
                {
                    $memberPermissionlevel = 'Full Control'
                }
                'FullRead'
                {
                    $memberPermissionlevel = 'Full Read'
                }
            }

            $member.Username = $memberName
            $member.PermissionLevel = $memberPermissionlevel
            $member.ActAsSystemAccount = $policy.IsSystemUser
            $member.IdentityType = $identityType
            $members += $member
        }

        $returnval = @{
                WebAppUrl = $params.WebAppUrl
                Members = $members
                MembersToInclude = $params.MembersToInclude
                MembersToExclude = $params.MembersToExclude
                SetCacheAccountsPolicy = $SetCacheAccountsPolicy
                InstallAccount = $params.InstallAccount
        }
        
        return $returnval
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
        $WebAppUrl,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Members,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $MembersToInclude,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $MembersToExclude,

        [Parameter()] 
        [System.Boolean] 
        $SetCacheAccountsPolicy,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting web app policy for $WebAppUrl"

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

    foreach ($member in $Members)
    {
        if (($member.ActAsSystemAccount -eq $true) -and `
            ($member.PermissionLevel -ne "Full Control"))
        {
            throw ("Members Parameter: You cannot specify ActAsSystemAccount " + `
                  "with any other permission than Full Control")
        }
    }

    foreach ($member in $MembersToInclude)
    {
        if (($member.ActAsSystemAccount -eq $true) -and `
            ($member.PermissionLevel -ne "Full Control"))
        {
            throw ("MembersToInclude Parameter: You cannot specify ActAsSystemAccount " + `
                  "with any other permission than Full Control")
        }
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters


    $modulePath = "..\..\Modules\SharePointDsc.WebAppPolicy\SPWebAppPolicy.psm1"
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath $modulePath -Resolve)
    
    if ($null -eq $CurrentValues)
    {
        throw "Web application does not exist"
    }

    $cacheAccounts = Get-SPDSCCacheAccountConfiguration -InputParameters $WebAppUrl
    
    if ($SetCacheAccountsPolicy)
    {
        if ($cacheAccounts.SuperUserAccount -eq "" -or $cacheAccounts.SuperReaderAccount -eq "")
        {
            throw ("Cache accounts not configured properly. PortalSuperUserAccount or " + `
                  "PortalSuperReaderAccount property is not configured.")
        }
    }

    # Determine the default identity type to use for entries that do not have it specified
    $defaultIdentityType = Invoke-SPDSCCommand -Credential $InstallAccount `
                                               -Arguments $PSBoundParameters `
                                               -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl
        if ($wa.UseClaimsAuthentication -eq $true)
        {
            return "Claims"
        } 
        else 
        {
            return "Native"
        }
    }

    $changeUsers = @()

    if ($Members -or $MembersToInclude)
    {
        $allMembers = @()
        if ($Members)
        {
            Write-Verbose -Message "Members property is set - setting full membership list"
            $membersToCheck = $Members
        }
        if ($MembersToInclude)
        {
            Write-Verbose -Message ("MembersToInclude property is set - setting membership " + `
                                    "list to ensure specified members are included")
            $membersToCheck = $MembersToInclude
        }
        foreach ($member in $membersToCheck)
        {
            $allMembers += $member
        }

        # Determine if cache accounts are to be included users
        if ($SetCacheAccountsPolicy)
        {
            Write-Verbose -Message "SetCacheAccountsPolicy is True - Adding Cache Accounts to list"
            $psuAccount = @{
                UserName = $cacheAccounts.SuperUserAccount
                PermissionLevel = "Full Control"
                IdentityMode = $cacheAccounts.IdentityMode
            }
            $allMembers += $psuAccount
            
            $psrAccount = @{
                UserName = $cacheAccounts.SuperReaderAccount
                PermissionLevel = "Full Read"
                IdentityMode = $cacheAccounts.IdentityMode
            }
            $allMembers += $psrAccount
        }

        # Get the list of differences from the current configuration
        $differences = Compare-SPDSCWebAppPolicy -WAPolicies $CurrentValues.Members `
                                                 -DSCSettings $allMembers `
                                                 -DefaultIdentityType $defaultIdentityType

        foreach ($difference in $differences)
        {
            switch ($difference.Status)
            {
                Additional {
                    # Only remove users if the "Members" property was set 
                    # instead of "MembersToInclude"
                    if ($Members)
                    {
                        $user = @{
                            Type     = "Delete"
                            Username = $difference.Username
                            IdentityMode = $difference.IdentityType
                        }
                    }
                }
                Different {
                    $user = @{
                        Type     = "Change"
                        Username = $difference.Username
                        PermissionLevel    = $difference.DesiredPermissionLevel
                        ActAsSystemAccount = $difference.DesiredActAsSystemSetting
                        IdentityMode = $difference.IdentityType
                    }
                }
                Missing  {
                    $user = @{
                        Type     = "Add"
                        Username = $difference.Username
                        PermissionLevel    = $difference.DesiredPermissionLevel
                        ActAsSystemAccount = $difference.DesiredActAsSystemSetting
                        IdentityMode = $difference.IdentityType 
                    }
                }
            }
            $changeUsers += $user
        }
    }

    if ($MembersToExclude)
    {
        Write-Verbose -Message ("MembersToExclude property is set - setting membership list " + `
                                "to ensure specified members are not included")

        foreach ($member in $MembersToExclude)
        {
            $policy = $CurrentValues.Members | Where-Object -FilterScript {
                $_.UserName -eq $member.UserName -and $_.IdentityType -eq $identityType
            }

            if (($cacheAccounts.SuperUserAccount -eq $member.Username) -or `
                ($cacheAccounts.SuperReaderAccount -eq $member.Username))
            {
                throw "You cannot exclude the Cache accounts from the Web Application Policy"
            }

            if ($null -ne $policy)
            {
                $user = @{
                    Type     = "Delete"
                    Username = $member.UserName
                }
            }
            $changeUsers += $user
        }
    }
    
    ## Perform changes
    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters,$PSScriptRoot,$changeUsers) `
                        -ScriptBlock {
        $params      = $args[0]
        $scriptRoot  = $args[1]
        $changeUsers = $args[2]

        $modulePath = "..\..\Modules\SharePointDsc.WebAppPolicy\SPWebAppPolicy.psm1"
        Import-Module -Name (Join-Path -Path $scriptRoot -ChildPath $modulePath -Resolve)

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

        if ($null -eq $wa)
        {
            throw "Specified web application could not be found."
        }

        $denyAll     = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::DenyAll)
        $denyWrite   = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::DenyWrite)
        $fullControl = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullControl)
        $fullRead    = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullRead)

        Write-Verbose -Message "Processing changes"

        foreach ($user in $changeUsers)
        {
            switch ($user.Type)
            {
                "Add" {
                    # User does not exist. Add user
                    Write-Verbose -Message "Adding $($user.Username)"
                    
                    $userToAdd = $user.Username
                    if ($user.IdentityMode -eq "Claims")
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $user.Username
                        if ($isUser -eq $true)
                        {
                            $principal = New-SPClaimsPrincipal -Identity $user.Username `
                                                               -IdentityType WindowsSamAccountName
                            $userToAdd = $principal.ToEncodedString()
                        } 
                        else 
                        {
                            $principal = New-SPClaimsPrincipal -Identity $user.Username `
                                                               -IdentityType WindowsSecurityGroupName
                            $userToAdd = $principal.ToEncodedString()
                        }    
                    }
                    $newPolicy = $wa.Policies.Add($userToAdd, $user.UserName)
                    foreach ($permissionLevel in $user.PermissionLevel)
                    {
                        switch ($permissionLevel)
                        {
                            "Deny All" {
                                $newPolicy.PolicyRoleBindings.Add($denyAll)
                            }
                            "Deny Write" {
                                $newPolicy.PolicyRoleBindings.Add($denyWrite)
                            }
                            "Full Control" {
                                $newPolicy.PolicyRoleBindings.Add($fullControl)
                            }
                            "Full Read" {
                                $newPolicy.PolicyRoleBindings.Add($fullRead)
                            }
                        }
                    }
                    if ($user.ActAsSystemAccount)
                    {
                        $newPolicy.IsSystemUser = $user.ActAsSystemAccount
                    }
                }
                "Change" {
                    # User exists. Check permissions
                    $userToChange = $user.Username
                    if ($user.IdentityMode -eq "Claims")
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $user.Username
                        if ($isUser -eq $true)
                        {
                            $principal = New-SPClaimsPrincipal -Identity $user.Username `
                                                               -IdentityType WindowsSamAccountName
                            $userToChange = $principal.ToEncodedString()
                        } 
                        else 
                        {
                            $principal = New-SPClaimsPrincipal -Identity $user.Username `
                                                               -IdentityType WindowsSecurityGroupName
                            $userToChange = $principal.ToEncodedString()
                        }
                    }
                    $policy = $wa.Policies | Where-Object -FilterScript {
                        $_.UserName -eq $userToChange 
                    }

                    Write-Verbose -Message "User $($user.Username) exists, checking permissions"
                    if ($user.ActAsSystemAccount -ne $policy.IsSystemUser)
                    {
                        $policy.IsSystemUser = $user.ActAsSystemAccount 
                    }

                    switch ($policy.PolicyRoleBindings.Type)
                    {
                        'DenyAll'
                        {
                            $userPermissionlevel = 'Deny All'
                        }
                        'DenyWrite'
                        {
                            $userPermissionlevel = 'Deny Write'
                        }
                        'FullControl'
                        {
                            $userPermissionlevel = 'Full Control'
                        }
                        'FullRead'
                        {
                            $userPermissionlevel = 'Full Read'
                        }
                    }

                    $polbinddiff = Compare-Object -ReferenceObject $userPermissionlevel `
                                                  -DifferenceObject $user.PermissionLevel
                    if ($null -ne $polbinddiff)
                    {
                        $policy.PolicyRoleBindings.RemoveAll()
                        foreach ($permissionLevel in $user.PermissionLevel)
                        {
                            switch ($permissionLevel)
                            {
                                "Deny All" {
                                    $policy.PolicyRoleBindings.Add($denyAll)
                                }
                                "Deny Write" {
                                    $policy.PolicyRoleBindings.Add($denyWrite)
                                }
                                "Full Control" {
                                    $policy.PolicyRoleBindings.Add($fullControl)
                                }
                                "Full Read" {
                                    $policy.PolicyRoleBindings.Add($fullRead)
                                }
                            }
                        }
                    }
                }
                "Delete" 
                {
                    Write-Verbose -Message "Removing $($user.Username)"
                    $userToDrop = $user.Username
                    if ($user.IdentityMode -eq "Claims")
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $user.Username
                        if ($isUser -eq $true)
                        {
                            $principal = New-SPClaimsPrincipal -Identity $user.Username `
                                                               -IdentityType WindowsSamAccountName
                            $userToDrop = $principal.ToEncodedString()
                        } 
                        else 
                        {
                            $principal = New-SPClaimsPrincipal -Identity $user.Username `
                                                               -IdentityType WindowsSecurityGroupName
                            $userToDrop = $principal.ToEncodedString()
                        }    
                    }
                    Remove-SPDSCGenericObject -SourceCollection $wa.Policies `
                                              -Target $userToDrop `
                                              -ErrorAction SilentlyContinue
                }
            }
        }
        $wa.Update()
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
        $WebAppUrl,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Members,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $MembersToInclude,

        [Parameter()] 
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $MembersToExclude,

        [Parameter()] 
        [System.Boolean] 
        $SetCacheAccountsPolicy,

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing web app policy for $WebAppUrl"

    $CurrentValues = Get-TargetResource @PSBoundParameters
    
    $modulePath = "..\..\Modules\SharePointDsc.WebAppPolicy\SPWebAppPolicy.psm1"
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath $modulePath -Resolve)

    if ($null -eq $CurrentValues)
    {
        return $false 
    }

    $cacheAccounts = Get-SPDSCCacheAccountConfiguration -InputParameters $WebAppUrl
    if ($SetCacheAccountsPolicy)
    {
        if (($cacheAccounts.SuperUserAccount -eq "") -or `
            ($cacheAccounts.SuperReaderAccount -eq ""))
        {
            throw "Cache accounts not configured properly. PortalSuperUserAccount or " + `
                  "PortalSuperReaderAccount property is not configured."
        }
    }

    # Determine the default identity type to use for entries that do not have it specified
    $defaultIdentityType = Invoke-SPDSCCommand -Credential $InstallAccount `
                                               -Arguments $PSBoundParameters `
                                               -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl
        if ($wa.UseClaimsAuthentication -eq $true)
        {
            return "Claims"
        } 
        else 
        {
            return "Native"
        }
    }
    
    # If checking the full members list, or the list of members to include then build the 
    # appropriate members list and check for the output of Compare-SPDSCWebAppPolicy
    if ($Members -or $MembersToInclude)
    {
        $allMembers = @()
        if ($Members)
        {
            Write-Verbose -Message "Members property is set - testing full membership list"
            $membersToCheck = $Members
        }
        if ($MembersToInclude)
        {
            Write-Verbose -Message ("MembersToInclude property is set - testing membership " + `
                                    "list to ensure specified members are included")
            $membersToCheck = $MembersToInclude
        }
        foreach ($member in $membersToCheck)
        {
            $allMembers += $member
        }

        # Determine if cache accounts are to be included users
        if ($SetCacheAccountsPolicy)
        {
            Write-Verbose -Message "SetCacheAccountsPolicy is True - Adding Cache Accounts to list"
            $psuAccount = @{
                UserName = $cacheAccounts.SuperUserAccount
                PermissionLevel = "Full Control"
                IdentityMode = $cacheAccounts.IdentityMode
            }
            $allMembers += $psuAccount
            
            $psrAccount = @{
                UserName = $cacheAccounts.SuperReaderAccount
                PermissionLevel = "Full Read"
                IdentityMode = $cacheAccounts.IdentityMode
            }
            $allMembers += $psrAccount
        }

        # Get the list of differences from the current configuration
        $differences = Compare-SPDSCWebAppPolicy -WAPolicies $CurrentValues.Members `
                                                 -DSCSettings $allMembers `
                                                 -DefaultIdentityType $defaultIdentityType
        
        # If checking members, any difference counts as a fail
        if ($Members)
        {
            if ($differences.Count -eq 0)
            {
                return $true 
            } 
            else 
            {
                Write-Verbose -Message "Differences in the policy were found, returning false" 
                return $false 
            }
        }

        # If only checking members to include only differences or missing records count as a fail
        if ($MembersToInclude)
        {
            if (($differences | Where-Object -FilterScript {
                    $_.Status -eq "Different" -or $_.Status -eq "Missing" 
                }).Count -eq 0)
            {
                return $true 
            } 
            else 
            {
                Write-Verbose -Message "Different or Missing policy was found, returning false" 
                return $false 
            }
        }
    }

    # If checking members to exlclude, simply compare the list of user names to the current
    # membership list
    if ($MembersToExclude)
    {
        Write-Verbose -Message ("MembersToExclude property is set - checking for permissions " + `
                                "that need to be removed")
        foreach ($member in $MembersToExclude)
        {
            if (($cacheAccounts.SuperUserAccount -eq $member.Username) -or `
                ($cacheAccounts.SuperReaderAccount -eq $member.Username))
            {
                throw "You cannot exclude the Cache accounts from the Web Application Policy"
            }
            
            foreach ($policy in $CurrentValues.Members)
            {
                if ($policy.Username -eq $member.Username)
                {
                    return $false
                }
            }
        }
        return $true
    }
}

function Get-SPDSCCacheAccountConfiguration()
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter()]
        [Object[]]  
        $InputParameters
    )
    
    $cacheAccounts = Invoke-SPDSCCommand -Credential $InstallAccount `
                                         -Arguments $InputParameters `
                                         -ScriptBlock {
        Write-Verbose -Message "Retrieving CacheAccounts"
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params -ErrorAction SilentlyContinue

        if ($null -eq $wa)
        {
            throw "Specified web application could not be found."
        }

        $returnval = @{
            SuperUserAccount = ""               
            SuperReaderAccount = ""
        }

        if ($wa.Properties.ContainsKey("portalsuperuseraccount"))
        {
            $memberName = $wa.Properties["portalsuperuseraccount"]
            if ($wa.UseClaimsAuthentication -eq $true)
            {
                $convertedClaim = New-SPClaimsPrincipal -Identity $memberName `
                                                        -IdentityType EncodedClaim `
                                                        -ErrorAction SilentlyContinue
                if($null -ne $convertedClaim)
                {
                    $memberName = $convertedClaim.Value
                }
            }
            $returnval.SuperUserAccount = $memberName
        }
        if ($wa.Properties.ContainsKey("portalsuperreaderaccount"))
        {
            $memberName = $wa.Properties["portalsuperreaderaccount"]
            if ($wa.UseClaimsAuthentication -eq $true)
            {
                $convertedClaim = New-SPClaimsPrincipal -Identity $memberName `
                                                        -IdentityType EncodedClaim `
                                                        -ErrorAction SilentlyContinue
                if($null -ne $convertedClaim)
                {
                    $memberName = $convertedClaim.Value
                }
            }
            $returnval.SuperReaderAccount = $memberName
        }

        if ($wa.UseClaimsAuthentication -eq $true)
        {
            $returnval.IdentityMode = "Claims"
        } 
        else 
        {
            $returnval.IdentityMode = "Native"
        }
        
        return $returnval
    }

    return $cacheAccounts
}

Export-ModuleMember -Function *-TargetResource
