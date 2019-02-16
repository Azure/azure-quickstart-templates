function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserProfileServiceAppName,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $FarmAccount,

        [Parameter()]
        [System.Boolean]
        $RunOnlyWhenWriteable,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting user profile sync service for $UserProfileServiceAppName"

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -ne 15)
    {
        throw [Exception] ("Only SharePoint 2013 is supported to deploy the user profile sync " + `
                           "service via DSC, as 2016/2019 do not use the FIM based sync service.")
    }

    $farmAccount = Invoke-SPDSCCommand -Credential $InstallAccount `
                                       -Arguments $PSBoundParameters `
                                       -ScriptBlock {
        return Get-SPDscFarmAccount
    }

    if ($null -ne $farmAccount)
    {
        if ($PSBoundParameters.ContainsKey("InstallAccount") -eq $true)
        {
            # InstallAccount used
            if ($InstallAccount.UserName -eq $farmAccount.UserName)
            {
                throw ("Specified InstallAccount ($($InstallAccount.UserName)) is the Farm " + `
                       "Account. Make sure the specified InstallAccount isn't the Farm Account " + `
                       "and try again")
            }
        }
        else {
            # PSDSCRunAsCredential or System
            if (-not $Env:USERNAME.Contains("$"))
            {
                # PSDSCRunAsCredential used
                $localaccount = "$($Env:USERDOMAIN)\$($Env:USERNAME)"
                if ($localaccount -eq $farmAccount.UserName)
                {
                    throw ("Specified PSDSCRunAsCredential ($localaccount) is the Farm " + `
                           "Account. Make sure the specified PSDSCRunAsCredential isn't the " + `
                           "Farm Account and try again")
                }
            }
        }
    }
    else
    {
        throw ("Unable to retrieve the Farm Account. Check if the farm exists.")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $services = Get-SPServiceInstance -Server $env:COMPUTERNAME `
                        -ErrorAction SilentlyContinue

        if ($null -eq $services)
        {
            return @{
                UserProfileServiceAppName = $params.UserProfileServiceAppName
                Ensure = "Absent"
                RunOnlyWhenWriteable = $params.RunOnlyWhenWriteable
                InstallAccount = $params.InstallAccount
            }
        }

        $syncService = $services | Where-Object -FilterScript {
            $_.GetType().Name -eq "ProfileSynchronizationServiceInstance"
        }

        if ($null -eq $syncService)
        {
            $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
            $currentServer = "$($env:COMPUTERNAME).$domain"
            $services = Get-SPServiceInstance -Server $currentServer `
                                                  -ErrorAction SilentlyContinue
            $syncService = $services | Where-Object -FilterScript {
                $_.GetType().Name -eq "ProfileSynchronizationServiceInstance"
            }
        }

        if ($null -eq $syncService)
        {
            return @{
                UserProfileServiceAppName = $params.UserProfileServiceAppName
                Ensure = "Absent"
                RunOnlyWhenWriteable = $params.RunOnlyWhenWriteable
                InstallAccount = $params.InstallAccount
            }
        }
        if ($null -ne $syncService.UserProfileApplicationGuid -and `
            $syncService.UserProfileApplicationGuid -ne [Guid]::Empty)
        {
            $upa = Get-SPServiceApplication -Identity $syncService.UserProfileApplicationGuid `
                                         -ErrorAction SilentlyContinue
        }
        if ($syncService.Status -eq "Online")
        {
            $localEnsure = "Present"
        }
        else
        {
            $localEnsure = "Absent"
        }

        return @{
            UserProfileServiceAppName = $upa.Name
            Ensure = $localEnsure
            FarmAccount = $params.FarmAccount
            RunOnlyWhenWriteable = $params.RunOnlyWhenWriteable
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
        $UserProfileServiceAppName,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $FarmAccount,

        [Parameter()]
        [System.Boolean]
        $RunOnlyWhenWriteable,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting user profile sync service for $UserProfileServiceAppName"

    $PSBoundParameters.Ensure = $Ensure

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -ne 15)
    {
        throw [Exception] ("Only SharePoint 2013 is supported to deploy the user profile sync " + `
                           "service via DSC, as 2016/2019 do not use the FIM based sync service.")
    }

    $farmAccount = Invoke-SPDSCCommand -Credential $InstallAccount `
                                           -Arguments $PSBoundParameters `
                                           -ScriptBlock {
        return Get-SPDscFarmAccount
    }

    if ($null -ne $farmAccount)
    {
        if ($PSBoundParameters.ContainsKey("InstallAccount") -eq $true)
        {
            # InstallAccount used
            if ($InstallAccount.UserName -eq $farmAccount.UserName)
            {
                throw ("Specified InstallAccount ($($InstallAccount.UserName)) is the Farm " + `
                       "Account. Make sure the specified InstallAccount isn't the Farm Account " + `
                       "and try again")
            }
        }
        else {
            # PSDSCRunAsCredential or System
            if (-not $Env:USERNAME.Contains("$"))
            {
                # PSDSCRunAsCredential used
                $localaccount = "$($Env:USERDOMAIN)\$($Env:USERNAME)"
                if ($localaccount -eq $farmAccount.UserName)
                {
                    throw ("Specified PSDSCRunAsCredential ($localaccount) is the Farm " + `
                           "Account. Make sure the specified PSDSCRunAsCredential isn't the " + `
                           "Farm Account and try again")
                }
            }
        }
    }
    else
    {
        throw ("Unable to retrieve the Farm Account. Check if the farm exists.")
    }

    if ($PSBoundParameters.ContainsKey("RunOnlyWhenWriteable") -eq $true)
    {
        $databaseReadOnly = Test-SPDscUserProfileDBReadOnly `
                                -UserProfileServiceAppName $UserProfileServiceAppName `
                                -InstallAccount $InstallAccount

        if ($databaseReadOnly)
        {
            Write-Verbose -Message ("User profile database is read only, setting user profile " + `
                                   "sync service to not run on the local server")
            $PSBoundParameters.Ensure = "Absent"
        }
        else
        {
            $PSBoundParameters.Ensure = "Present"
        }
    }

    # Add the Farm Account to the local Admins group, if it's not already there
    $isLocalAdmin = Test-SPDSCUserIsLocalAdmin -UserName $farmAccount.UserName

    if (!$isLocalAdmin)
    {
        Write-Verbose -Message "Adding farm account to Local Administrators group"
        Add-SPDSCUserToLocalAdmin -UserName $farmAccount.UserName

        # Cycle the Timer Service and flush Kerberos tickets
        # so that it picks up the local Admin token
        Restart-Service -Name "SPTimerV4"

        Clear-SPDscKerberosToken -Account $farmAccount.UserName
    }

    $isInDesiredState = $false
    try
    {
        Invoke-SPDSCCommand -Credential $FarmAccount `
                            -Arguments ($PSBoundParameters,$farmAccount) `
                            -ScriptBlock {
            $params = $args[0]
            $farmAccount = $args[1]

            $currentServer = $env:COMPUTERNAME

            $services = Get-SPServiceInstance -Server $currentServer `
                                              -ErrorAction SilentlyContinue
            $syncService = $services | Where-Object -FilterScript {
                $_.GetType().Name -eq "ProfileSynchronizationServiceInstance"
            }
            if ($null -eq $syncService)
            {
                $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
                $currentServer = "$currentServer.$domain"
                $syncService = $services | Where-Object -FilterScript {
                    $_.GetType().Name -eq "ProfileSynchronizationServiceInstance"
                }
            }
            if ($null -eq $syncService)
            {
                throw "Unable to locate a user profile sync service instance on $currentServer to start"
            }

            # Start the Sync service if it should be running on this server
            if (($params.Ensure -eq "Present") -and ($syncService.Status -ne "Online"))
            {
                $ups = Get-SPServiceApplication -Name $params.UserProfileServiceAppName `
                                                        -ErrorAction SilentlyContinue
                if ($null -eq $ups)
                {
                    throw [Exception] ("No User Profile Service Application was found " + `
                                       "named $($params.UserProfileServiceAppName)")
                }

                $userName = $farmAccount.UserName
                $password = $farmAccount.GetNetworkCredential().Password
                $ups.SetSynchronizationMachine($currentServer, $syncService.ID, $userName, $password)

                Start-SPServiceInstance -Identity $syncService.ID

                $desiredState = "Online"
            }
            # Stop the Sync service in all other cases
            else
            {
                Stop-SPServiceInstance -Identity $syncService.ID -Confirm:$false
                $desiredState = "Disabled"
            }

            $count = 0
            $maxCount = 20

            while (($count -lt $maxCount) -and ($syncService.Status -ne $desiredState))
            {
                if ($syncService.Status -ne $desiredState)
                {
                    Start-Sleep -Seconds 60
                }

                # Get the current status of the Sync service
                Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - Waiting for user " + `
                                        "profile sync service to become '$desiredState' (waited " + `
                                        "$count of $maxCount minutes)")

                $services = Get-SPServiceInstance -Server $currentServer `
                                                  -ErrorAction SilentlyContinue
                $syncService = $services | Where-Object -FilterScript {
                    $_.GetType().Name -eq "ProfileSynchronizationServiceInstance"
                }
                $count++
            }
        }
    }
    finally
    {
        # Remove the Farm Account from the local Admins group, if it was added above
        if (!$isLocalAdmin)
        {
            Write-Verbose -Message "Removing farm account from Local Administrators group"
            Remove-SPDSCUserToLocalAdmin -UserName $farmAccount.UserName

            # Cycle the Timer Service and flush Kerberos tickets
            # so that it picks up the local Admin token
            Restart-Service -Name "SPTimerV4"

            Clear-SPDscKerberosToken -Account $farmAccount.UserName
        }
    }
    if($syncService.Status -ne $desiredState)
    {
        throw "An error occured. We couldn't properly set the User Profile Sync Service on the server."
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
        $UserProfileServiceAppName,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $FarmAccount,

        [Parameter()]
        [System.Boolean]
        $RunOnlyWhenWriteable,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing user profile sync service for $UserProfileServiceAppName"

    $PSBoundParameters.Ensure = $Ensure

    if ((Get-SPDSCInstalledProductVersion).FileMajorPart -ne 15)
    {
        throw [Exception] ("Only SharePoint 2013 is supported to deploy the user profile sync " + `
                           "service via DSC, as 2016/2019 do not use the FIM based sync service.")
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($PSBoundParameters.ContainsKey("RunOnlyWhenWriteable") -eq $true)
    {
        $databaseReadOnly = Test-SPDscUserProfileDBReadOnly `
                                -UserProfileServiceAppName $UserProfileServiceAppName `
                                -InstallAccount $InstallAccount

        if ($databaseReadOnly)
        {
            Write-Verbose -Message ("User profile database is read only, setting user profile " + `
                                   "sync service to not run on the local server")
            $PSBoundParameters.Ensure = "Absent"
        }
        else
        {
            $PSBoundParameters.Ensure = "Present"
        }
    }

    Write-Verbose -Message "Testing for User Profile Synchronization Service"

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

function Test-SPDscUserProfileDBReadOnly()
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $UserProfileServiceAppName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    $databaseReadOnly = Invoke-SPDSCCommand -Credential $InstallAccount `
                                            -Arguments $UserProfileServiceAppName `
                                            -ScriptBlock {
        $UserProfileServiceAppName = $args[0]

        $serviceApps = Get-SPServiceApplication -Name $UserProfileServiceAppName `
                                                -ErrorAction SilentlyContinue
        if ($null -eq $serviceApps)
        {
            throw [Exception] ("No user profile service was found " + `
                               "named $UserProfileServiceAppName")
        }
        $ups = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.Office.Server.Administration.UserProfileApplication"
        }

        $propType = $ups.GetType()
        $propData = $propType.GetProperties([System.Reflection.BindingFlags]::Instance -bor `
                                            [System.Reflection.BindingFlags]::NonPublic)
        $profileProp = $propData | Where-Object -FilterScript {
            $_.Name -eq "ProfileDatabase"
        }
        $profileDBName = $profileProp.GetValue($ups).Name

        $database = Get-SPDatabase | Where-Object -FilterScript {
            $_.Name -eq $profileDBName
        }
        return $database.IsReadyOnly
    }
    return $databaseReadOnly
}

Export-ModuleMember -Function *-TargetResource
