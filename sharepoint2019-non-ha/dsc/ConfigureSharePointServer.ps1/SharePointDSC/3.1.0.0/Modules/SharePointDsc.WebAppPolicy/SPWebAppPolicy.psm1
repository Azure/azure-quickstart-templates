function Assert-SPDSCPolicyUser() 
{
    Param (
        [Parameter(Mandatory=$false)]
        [Array] 
        $CurrentDifferences,

        [Parameter(Mandatory=$true)]
        [String] 
        $UsernameToCheck
    )

    foreach ($difference in $CurrentDifferences) 
    {
        if($difference.ContainsKey($UsernameToCheck)) 
        {
            return $true 
        }
    }
    return $false
}

function Compare-SPDSCWebAppPolicy() 
{
    Param (
        [Parameter(Mandatory=$true)] 
        [Array] 
        $WAPolicies,

        [Parameter(Mandatory=$true)] 
        [Array] 
        $DSCSettings,

        [Parameter(Mandatory=$true)] 
        [String] 
        $DefaultIdentityType
    )
    Import-Module -Name (Join-Path -Path $PSScriptRoot `
                                   -ChildPath "..\SharePointDsc.Util\SharePointDsc.Util.psm1" `
                                   -Resolve)
    $diff = @()

    foreach ($policy in $WAPolicies) 
    {
        $memberexists = $false
        foreach($setting in $DSCSettings) 
        {
            $identityType = $DefaultIdentityType
            if ((Test-SPDSCObjectHasProperty -Object $setting `
                                             -PropertyName "IdentityType") -eq $true) 
            {
                $identityType = $setting.IdentityType
            }
            if (($policy.Username -eq $setting.Username) -and `
                ($policy.IdentityType -eq $identityType)) 
            {

                $memberexists = $true

                $polbinddiff = Compare-Object -ReferenceObject $policy.PermissionLevel.ToLower() `
                                              -DifferenceObject $setting.PermissionLevel.ToLower()

                if ($null -ne $polbinddiff) 
                {
                    Write-Verbose -Message ("Permission level different for " + `
                                            "$($policy.IdentityType) user '$($policy.Username)'")

                    if (-not (Assert-SPDSCPolicyUser -CurrentDifferences $diff `
                                                     -UsernameToCheck $policy.Username.ToLower())) 
                    {
                        $diff += @{
                            Username = $policy.Username.ToLower()
                            Status = "Different"
                            IdentityType = $policy.IdentityType
                            DesiredPermissionLevel = $setting.PermissionLevel
                            DesiredActAsSystemSetting = $setting.ActAsSystemAccount
                        }
                    }
                }
                
                if ($setting.ActAsSystemAccount) 
                {
                    if ($policy.ActAsSystemAccount -ne $setting.ActAsSystemAccount) 
                    {
                        Write-Verbose -Message ("System User different for " + `
                                               "$($policy.IdentityType) user '$($policy.Username)'")

                        if (-not (Assert-SPDSCPolicyUser -CurrentDifferences $diff `
                                                         -UsernameToCheck $policy.Username.ToLower())) 
                        {
                            $diff += @{
                                Username = $policy.Username.ToLower()
                                Status = "Different"
                                IdentityType = $policy.IdentityType
                                DesiredPermissionLevel = $setting.PermissionLevel
                                DesiredActAsSystemSetting = $setting.ActAsSystemAccount
                            }
                        }
                    }
                }
            }
        }

        if (-not $memberexists) 
        {
            if (-not (Assert-SPDSCPolicyUser -CurrentDifferences $diff `
                                             -UsernameToCheck $policy.Username.ToLower())) 
            {
                $diff += @{
                    Username = $policy.Username.ToLower()
                    Status = "Additional"
                    IdentityType = $policy.IdentityType
                    DesiredPermissionLevel = $null
                    DesiredActAsSystemSetting = $null
                } 
            }
        }
    }

    foreach ($setting in $DSCSettings) 
    {
        $memberexists = $false
        $identityType = $DefaultIdentityType
        if ((Test-SPDSCObjectHasProperty -Object $setting -PropertyName "IdentityType") -eq $true) 
        {
            $identityType = $setting.IdentityType
        }
        foreach($policy in $WAPolicies) 
        {
            if (($policy.Username -eq $setting.Username) -and `
                ($policy.IdentityType -eq $identityType)) 
            {
                $memberexists = $true

                $polbinddiff = Compare-Object -ReferenceObject $policy.PermissionLevel.ToLower() `
                                              -DifferenceObject $setting.PermissionLevel.ToLower()
                if ($null -ne $polbinddiff) 
                {
                    Write-Verbose -Message ("Permission level different for " + `
                                           "$($policy.IdentityType) user '$($policy.Username)'")

                    if (-not (Assert-SPDSCPolicyUser -CurrentDifferences $diff `
                                                     -UsernameToCheck $policy.Username.ToLower())) 
                    {
                        $diff += @{
                            Username = $setting.Username.ToLower()
                            Status = "Different"
                            IdentityType = $identityType
                            DesiredPermissionLevel = $setting.PermissionLevel
                            DesiredActAsSystemSetting = $setting.ActAsSystemAccount
                        }
                    }
                }

                if ($setting.ActAsSystemAccount) 
                {
                    if ($policy.ActAsSystemAccount -ne $setting.ActAsSystemAccount) 
                    {
                        Write-Verbose -Message ("System User different for " + `
                                               "$($policy.IdentityType) user '$($policy.Username)'")

                        if (-not (Assert-SPDSCPolicyUser -CurrentDifferences $diff `
                                                         -UsernameToCheck $policy.Username.ToLower())) 
                        {
                            $diff += @{
                                Username = $setting.Username.ToLower()
                                Status = "Different"
                                IdentityType = $identityType
                                DesiredPermissionLevel = $setting.PermissionLevel
                                DesiredActAsSystemSetting = $setting.ActAsSystemAccount
                            }
                        }
                    }
                }
            }
        }
        
        if (-not $memberexists) 
        {
            if (-not (Assert-SPDSCPolicyUser -CurrentDifferences $diff `
                                             -UsernameToCheck $setting.Username.ToLower())) 
            {
                $diff += @{
                    Username = $setting.Username.ToLower()
                    Status = "Missing"
                    IdentityType = $identityType
                    DesiredPermissionLevel = $setting.PermissionLevel
                    DesiredActAsSystemSetting = $setting.ActAsSystemAccount
                } 
            }
        }
    }
    return $diff
}
