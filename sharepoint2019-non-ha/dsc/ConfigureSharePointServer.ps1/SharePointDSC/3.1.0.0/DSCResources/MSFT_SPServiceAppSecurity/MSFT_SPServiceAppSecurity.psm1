function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Administrators","SharingPermissions")]
        [System.String]
        $SecurityType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Members,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting all security options for $SecurityType in $ServiceAppName"

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        throw ("Cannot use the Members parameter together with the MembersToInclude or " + `
               "MembersToExclude parameters")
    }

    if ($null -eq $Members -and $null -eq $MembersToInclude -and $null -eq $MembersToExclude)
    {
        throw ("At least one of the following parameters must be specified: Members, " + `
               "MembersToInclude, MembersToExclude")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $serviceApp = Get-SPServiceApplication -Name $params.ServiceAppName

        if ($null -eq $serviceApp)
        {
            return @{
                ServiceAppName = ""
                SecurityType = $params.SecurityType
                InstallAccount = $params.InstallAccount
            }
        }

        switch ($params.SecurityType)
        {
            "Administrators" {
                $security = $serviceApp | Get-SPServiceApplicationSecurity -Admin
             }
            "SharingPermissions" {
                $security = $serviceApp | Get-SPServiceApplicationSecurity
            }
        }

        $members = @()
        foreach ($securityEntry in $security.AccessRules)
        {
            $user = $securityEntry.Name
            if ($user -like "i:*|*" -or $user -like "c:*|*")
            {
                if ($user.Chars(3) -eq "%" -and $user -ilike "*$((Get-SPFarm).Id.ToString())")
                {
                    $user = "{LocalFarm}"
                }
                else
                {
                    $user = (New-SPClaimsPrincipal -Identity $user -IdentityType EncodedClaim).Value
                    if ($user -match "^s-1-[0-59]-\d+-\d+-\d+-\d+-\d+")
                    {
                        $user = Resolve-SPDscSecurityIdentifier -SID $user
                    }
                }
            }

            $accessLevels = @()

            foreach ($namedAccessRight in $security.NamedAccessRights)
            {
                if ($namedAccessRight.Rights.IsSubsetOf($securityEntry.AllowedObjectRights))
                {
                    $accessLevels += $namedAccessRight.Name
                }
            }

            $members += @{
                Username    = $user
                AccessLevels = $accessLevels
            }
        }

        return @{
            ServiceAppName   = $params.ServiceAppName
            SecurityType     = $params.SecurityType
            Members          = $members
            MembersToInclude = $params.MembersToInclude
            MembersToExclude = $params.MembersToExclude
            InstallAccount   = $params.InstallAccount
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
        $ServiceAppName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Administrators","SharingPermissions")]
        [System.String]
        $SecurityType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Members,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting all security options for $SecurityType in $ServiceAppName"

    if ($Members -and (($MembersToInclude) -or ($MembersToExclude)))
    {
        throw ("Cannot use the Members parameter together with the MembersToInclude or " + `
               "MembersToExclude parameters")
    }

    if ($null -eq $Members -and $null -eq $MembersToInclude -and $null -eq $MembersToExclude)
    {
        throw ("At least one of the following parameters must be specified: Members, " + `
               "MembersToInclude, MembersToExclude")
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ([System.String]::IsNullOrEmpty($CurrentValues.ServiceAppName) -eq $true)
    {
        throw "Unable to locate service application $ServiceAppName"
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters, $CurrentValues) `
                        -ScriptBlock {
        $params = $args[0]
        $CurrentValues = $args[1]

        $serviceApp = Get-SPServiceApplication -Name $params.ServiceAppName
        switch ($params.SecurityType)
        {
            "Administrators" {
                $security = $serviceApp | Get-SPServiceApplicationSecurity -Admin
             }
            "SharingPermissions" {
                $security = $serviceApp | Get-SPServiceApplicationSecurity
            }
        }

        $localFarmEncodedClaim = "c:0%.c|system|$((Get-SPFarm).Id.ToString())"

        if ($params.ContainsKey("Members") -eq $true)
        {
            foreach($desiredMember in $params.Members)
            {
                if ($desiredMember.Username -eq "{LocalFarm}")
                {
                    $claim = New-SPClaimsPrincipal -Identity $localFarmEncodedClaim `
                                                   -IdentityType EncodedClaim
                }
                else
                {
                    $isUser = Test-SPDSCIsADUser -IdentityName $desiredMember.Username
                    if ($isUser -eq $true)
                    {
                        $claim = New-SPClaimsPrincipal -Identity $desiredMember.Username `
                                                       -IdentityType WindowsSamAccountName
                    }
                    else
                    {
                        $claim = New-SPClaimsPrincipal -Identity $desiredMember.Username `
                                                       -IdentityType WindowsSecurityGroupName
                    }
                }

                if ($CurrentValues.Members.Username -contains $desiredMember.Username)
                {
                    if ($null -ne (Compare-Object -ReferenceObject ($CurrentValues.Members | Where-Object -FilterScript {
                            $_.Username -eq $desiredMember.Username
                        } | Select-Object -First 1).AccessLevels -DifferenceObject $desiredMember.AccessLevels))
                    {
                        Grant-SPObjectSecurity -Identity $security `
                                               -Principal $claim `
                                               -Rights $desiredMember.AccessLevels `
                                               -Replace
                    }
                }
                else
                {
                    Grant-SPObjectSecurity -Identity $security -Principal $claim -Rights $desiredMember.AccessLevels
                }
            }

            foreach($currentMember in $CurrentValues.Members)
            {
                if ($params.Members.Username -notcontains $currentMember.Username)
                {
                    if ($currentMember.UserName -eq "{LocalFarm}")
                    {
                        $claim = New-SPClaimsPrincipal -Identity $localFarmEncodedClaim `
                                                    -IdentityType EncodedClaim
                    }
                    else
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $currentMember.Username
                        if ($isUser -eq $true)
                        {
                            $claim = New-SPClaimsPrincipal -Identity $currentMember.Username `
                                                        -IdentityType WindowsSamAccountName
                        }
                        else
                        {
                            $claim = New-SPClaimsPrincipal -Identity $currentMember.Username `
                                                        -IdentityType WindowsSecurityGroupName
                        }
                    }
                    Revoke-SPObjectSecurity -Identity $security -Principal $claim
                }
            }
        }

        if ($params.ContainsKey("MembersToInclude") -eq $true)
        {
            foreach ($desiredMember in $params.MembersToInclude)
            {
                if ($desiredMember.Username -eq "{LocalFarm}")
                {
                    $claim = New-SPClaimsPrincipal -Identity $localFarmEncodedClaim `
                                                   -IdentityType EncodedClaim
                }
                else
                {
                    $isUser = Test-SPDSCIsADUser -IdentityName $desiredMember.Username
                    if ($isUser -eq $true)
                    {
                        $claim = New-SPClaimsPrincipal -Identity $desiredMember.Username `
                                                    -IdentityType WindowsSamAccountName
                    }
                    else
                    {
                        $claim = New-SPClaimsPrincipal -Identity $desiredMember.Username `
                                                    -IdentityType WindowsSecurityGroupName
                    }
                }

                if ($CurrentValues.Members.Username -contains $desiredMember.Username)
                {
                    if ($null -ne (Compare-Object -ReferenceObject ($CurrentValues.Members | Where-Object -FilterScript {
                            $_.Username -eq $desiredMember.Username
                        } | Select-Object -First 1).AccessLevels -DifferenceObject $desiredMember.AccessLevels))
                    {
                        Grant-SPObjectSecurity -Identity $security `
                                               -Principal $claim `
                                               -Rights $desiredMember.AccessLevels `
                                               -Replace
                    }
                }
                else
                {
                    Grant-SPObjectSecurity -Identity $security `
                                           -Principal $claim `
                                           -Rights $desiredMember.AccessLevels
                }
            }
        }

        if ($params.ContainsKey("MembersToExclude") -eq $true)
        {
            foreach ($excludeMember in $params.MembersToExclude)
            {
                if ($CurrentValues.Members.Username -contains $excludeMember)
                {
                    if ($excludeMember -eq "{LocalFarm}")
                    {
                        $claim = New-SPClaimsPrincipal -Identity $localFarmEncodedClaim `
                                                       -IdentityType EncodedClaim
                    }
                    else
                    {
                        $isUser = Test-SPDSCIsADUser -IdentityName $excludeMember
                        if ($isUser -eq $true)
                        {
                            $claim = New-SPClaimsPrincipal -Identity $excludeMember `
                                                        -IdentityType WindowsSamAccountName
                        }
                        else
                        {
                            $claim = New-SPClaimsPrincipal -Identity $excludeMember `
                                                        -IdentityType WindowsSecurityGroupName
                        }
                    }
                    Revoke-SPObjectSecurity -Identity $security -Principal $claim
                }
            }
        }

        switch ($params.SecurityType)
        {
            "Administrators" {
                $security = $serviceApp | Set-SPServiceApplicationSecurity -ObjectSecurity $security `
                                                                           -Admin
             }
            "SharingPermissions" {
                $security = $serviceApp | Set-SPServiceApplicationSecurity -ObjectSecurity $security
            }
        }
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
        $ServiceAppName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Administrators","SharingPermissions")]
        [System.String]
        $SecurityType,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $Members,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $MembersToInclude,

        [Parameter()]
        [System.String[]]
        $MembersToExclude,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing all security options for $SecurityType in $ServiceAppName"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ([System.String]::IsNullOrEmpty($CurrentValues.ServiceAppName) -eq $true)
    {
        return $false
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters, $CurrentValues, $PSScriptRoot) `
                        -ScriptBlock {
        $params = $args[0]
        $CurrentValues = $args[1]
        $ScriptRoot = $args[2]

        $relPath = "..\..\Modules\SharePointDsc.ServiceAppSecurity\SPServiceAppSecurity.psm1"
        Import-Module (Join-Path -Path $ScriptRoot -ChildPath $relPath -Resolve)

        $serviceApp = Get-SPServiceApplication -Name $params.ServiceAppName
        switch ($params.SecurityType)
        {
            "Administrators" {
                $security = $serviceApp | Get-SPServiceApplicationSecurity -Admin
            }
            "SharingPermissions" {
                $security = $serviceApp | Get-SPServiceApplicationSecurity
            }
        }

        if ($null -ne $params.Members)
        {
            Write-Verbose -Message "Processing Members parameter"

            if ($CurrentValues.Members.Count -eq 0)
            {
                if ($params.Members.Count -gt 0)
                {
                    Write-Verbose -Message "Security list does not match"
                    return $false
                }
                else
                {
                    Write-Verbose -Message "Configured and specified security lists are both empty"
                    return $true
                }
            }
            elseif ($params.Members.Count -eq 0)
            {
                Write-Verbose -Message "Security list does not match"
                return $false
            }

            $differences = Compare-Object -ReferenceObject $CurrentValues.Members.Username `
                                            -DifferenceObject $params.Members.Username

            if ($null -eq $differences)
            {
                Write-Verbose -Message "Security list matches - checking that permissions match on each object"
                foreach($currentMember in $CurrentValues.Members)
                {
                    $expandedAccessLevels = Expand-AccessLevel -Security $security -AccessLevels ($params.Members | Where-Object -FilterScript {
                        $_.Username -eq $currentMember.Username
                    } | Select-Object -First 1).AccessLevels
                    if ($null -ne (Compare-Object -DifferenceObject $currentMember.AccessLevels -ReferenceObject $expandedAccessLevels))
                    {
                        Write-Verbose -Message "$($currentMember.Username) has incorrect permission level. Test failed."
                        return $false
                    }
                }
                return $true
            }
            else
            {
                Write-Verbose -Message "Security list does not match"
                return $false
            }
        }

        $result = $true
        if ($params.MembersToInclude)
        {
            Write-Verbose -Message "Processing MembersToInclude parameter"
            foreach ($member in $params.MembersToInclude)
            {
                if (-not($CurrentValues.Members.Username -contains $member.Username))
                {
                    Write-Verbose -Message "$($member.Username) does not have access. Set result to false"
                    $result = $false
                }
                else
                {
                    Write-Verbose -Message "$($member.Username) already has access. Checking permission..."
                    $expandedAccessLevels = Expand-AccessLevel -Security $security -AccessLevels $member.AccessLevels

                    if ($null -ne (Compare-Object -DifferenceObject $expandedAccessLevels -ReferenceObject ($CurrentValues.Members | Where-Object -FilterScript {
                            $_.Username -eq $member.Username
                        } | Select-Object -First 1).AccessLevels))
                    {
                        Write-Verbose -Message "$($member.Username) has incorrect permission level. Test failed."
                        return $false
                    }
                }
            }
        }

        if ($params.MembersToExclude)
        {
            Write-Verbose -Message "Processing MembersToExclude parameter"
            foreach ($member in $params.MembersToExclude)
            {
                if ($CurrentValues.Members.Username -contains $member)
                {
                    Write-Verbose -Message "$member already has access. Set result to false"
                    $result = $false
                }
                else
                {
                    Write-Verbose -Message "$member does not have access. Skipping"
                }
            }
        }

        return $result
    }

    return $result
}

Export-ModuleMember -Function *-TargetResource
