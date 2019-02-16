function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $CacheSizeInMB,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAccount,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $CreateFirewallRules,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $ServerProvisionOrder,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting the cache host information"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        $nullReturnValue = @{
            Name = $params.Name
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        }

        try
        {
            Use-CacheCluster -ErrorAction SilentlyContinue
            $cacheHost = Get-CacheHost -ErrorAction SilentlyContinue

            if ($null -eq $cacheHost)
            {
                return $nullReturnValue
            }
            $computerName = ([System.Net.Dns]::GetHostByName($env:computerName)).HostName
            $cachePort = ($cacheHost | Where-Object -FilterScript {
                $_.HostName -eq $computerName
            }).PortNo
            $cacheHostConfig = Get-AFCacheHostConfiguration -ComputerName $computerName `
                                                            -CachePort $cachePort `
                                                            -ErrorAction SilentlyContinue

            $windowsService = Get-CimInstance -Class Win32_Service -Filter "Name='AppFabricCachingService'"
            $firewallRule = Get-NetFirewallRule -DisplayName "SharePoint Distributed Cache" `
                                                -ErrorAction SilentlyContinue

            return @{
                Name = $params.Name
                CacheSizeInMB = $cacheHostConfig.Size
                ServiceAccount = $windowsService.StartName
                CreateFirewallRules = ($null -ne $firewallRule)
                Ensure = "Present"
                ServerProvisionOrder = $params.ServerProvisionOrder
                InstallAccount = $params.InstallAccount
            }
        }
        catch
        {
            return $nullReturnValue
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $CacheSizeInMB,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAccount,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $CreateFirewallRules,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $ServerProvisionOrder,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting the cache host information"

    $CurrentState = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq "Present")
    {
        Write-Verbose -Message "Adding the distributed cache to the server"
        if ($createFirewallRules -eq $true)
        {
            Write-Verbose -Message "Create a firewall rule for AppFabric"
            Invoke-SPDSCCommand -Credential $InstallAccount -ScriptBlock {
                $icmpRuleName = "File and Printer Sharing (Echo Request - ICMPv4-In)"
                $icmpFirewallRule = Get-NetFirewallRule -DisplayName $icmpRuleName `
                                                        -ErrorAction SilentlyContinue
                if ($null -eq $icmpFirewallRule )
                {
                    New-NetFirewallRule -Name Allow_Ping -DisplayName $icmpRuleName `
                                                         -Description "Allow ICMPv4 ping" `
                                                         -Protocol ICMPv4 `
                                                         -IcmpType 8 `
                                                         -Enabled True `
                                                         -Profile Any `
                                                         -Action Allow
                }
                Enable-NetFirewallRule -DisplayName $icmpRuleName

                $spRuleName = "SharePoint Distributed Cache"
                $firewallRule = Get-NetFirewallRule -DisplayName $spRuleName `
                                                    -ErrorAction SilentlyContinue
                if ($null -eq $firewallRule)
                {
                    New-NetFirewallRule -Name "SPDistCache" `
                                        -DisplayName $spRuleName `
                                        -Protocol TCP `
                                        -LocalPort 22233-22236 `
                                        -Group "SharePoint"
                }
                Enable-NetFirewallRule -DisplayName $spRuleName
            }
            Write-Verbose -Message "Firewall rule added"
        }

        Write-Verbose -Message ("Current state is '$($CurrentState.Ensure)' " + `
                                "and desired state is '$Ensure'")

        if ($CurrentState.Ensure -ne $Ensure)
        {
            Write-Verbose -Message "Enabling distributed cache service"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]

                if ($params.ContainsKey("ServerProvisionOrder"))
                {
                    $serverCount = 0
                    $currentServer = $params.ServerProvisionOrder[$serverCount]

                    while ($currentServer -ne $env:COMPUTERNAME)
                    {
                        $count = 0
                        $maxCount = 30

                        # Attempt to see if we can find the service with just the computer
                        # name, or if we need to use the FQDN
                        $si = Get-SPServiceInstance -Server $currentServer `
                            | Where-Object -FilterScript {
                                $_.GetType().Name -eq "SPDistributedCacheServiceInstance"
                        }

                        if ($null -eq $si)
                        {
                            $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
                            $currentServer = "$currentServer.$domain"
                        }

                        Write-Verbose "Waiting for cache on $currentServer"
                        $serviceCheck = Get-SPServiceInstance -Server $currentServer `
                            | Where-Object -FilterScript {
                                $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                                $_.Status -eq "Online"
                        }

                        while (($count -lt $maxCount) -and ($null -eq $serviceCheck))
                        {
                            Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - " + `
                                                    "Waiting for distributed cache to start " + `
                                                    "on $currentServer (waited $count of " + `
                                                    "$maxCount minutes)")
                            Start-Sleep -Seconds 60
                            $serviceCheck = Get-SPServiceInstance -Server $currentServer `
                                | Where-Object -FilterScript {
                                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                                    $_.Status -eq "Online"
                            }
                            $count++
                        }

                        $serviceCheck = Get-SPServiceInstance -Server $currentServer `
                                            | Where-Object -FilterScript {
                                                $_.GetType().Name -eq "SPDistributedCacheServiceInstance" `
                                                -and $_.Status -eq "Online"
                                            }

                        if ($null -eq $serviceCheck)
                        {
                            Write-Warning -Message ("Server $currentServer is not running " + `
                                                    "distributed cache after waiting 30 " + `
                                                    "minutes. No longer waiting for this " + `
                                                    "server, progressing to next action")
                        }

                        $serverCount++

                        if ($ServerCount -ge $params.ServerProvisionOrder.Length)
                        {
                            throw ("The server $($env:COMPUTERNAME) was not found in the " + `
                                   "array for distributed cache servers")
                        }
                        $currentServer = $params.ServerProvisionOrder[$serverCount]
                    }
                }

                Add-SPDistributedCacheServiceInstance

                Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance"
                } | Stop-SPServiceInstance -Confirm:$false

                $count = 0
                $maxCount = 30

                $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                    $_.Status -ne "Disabled"
                }

                while (($count -lt $maxCount) -and ($null -ne $serviceCheck))
                {
                    Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - Waiting " + `
                                            "for distributed cache to stop on all servers " + `
                                            "(waited $count of $maxCount minutes)")
                    Start-Sleep -Seconds 60
                    $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                        $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                        $_.Status -ne "Disabled"
                    }
                    $count++
                }

                Update-SPDistributedCacheSize -CacheSizeInMB $params.CacheSizeInMB

                Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance"
                } | Start-SPServiceInstance

                $count = 0
                $maxCount = 30

                $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                    $_.Status -ne "Online"
                }

                while (($count -lt $maxCount) -and ($null -ne $serviceCheck))
                {
                    Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - Waiting " + `
                                            "for distributed cache to start on all servers " + `
                                            "(waited $count of $maxCount minutes)")
                    Start-Sleep -Seconds 60
                    $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                        $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                        $_.Status -ne "Online"
                    }
                    $count++
                }

                $farm = Get-SPFarm
                $cacheService = $farm.Services | Where-Object -FilterScript {
                    $_.Name -eq "AppFabricCachingService"
                }

                if ($cacheService.ProcessIdentity.ManagedAccount.Username -ne $params.ServiceAccount)
                {
                    $cacheService.ProcessIdentity.CurrentIdentityType = "SpecificUser"
                    $account = Get-SPManagedAccount -Identity $params.ServiceAccount
                    $cacheService.ProcessIdentity.ManagedAccount = $account
                    $cacheService.ProcessIdentity.Update()
                    $cacheService.ProcessIdentity.Deploy()
                }
            }
        }
        elseif ($CurrentState.CacheSizeInMB -ne $CacheSizeInMB)
        {
            Write-Verbose -Message "Updating distributed cache service cache size"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]

                Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance"
                } | Stop-SPServiceInstance -Confirm:$false

                $count = 0
                $maxCount = 30

                $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                    $_.Status -ne "Disabled"
                }

                while (($count -lt $maxCount) -and ($null -ne $serviceCheck))
                {
                    Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - Waiting " + `
                                            "for distributed cache to stop on all servers " + `
                                            "(waited $count of $maxCount minutes)")
                    Start-Sleep -Seconds 60
                    $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                        $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                        $_.Status -ne "Disabled"
                    }
                    $count++
                }

                Update-SPDistributedCacheSize -CacheSizeInMB $params.CacheSizeInMB

                Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance"
                } | Start-SPServiceInstance

                $count = 0
                $maxCount = 30

                $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                    $_.Status -ne "Online"
                }

                while (($count -lt $maxCount) -and ($null -ne $serviceCheck))
                {
                    Write-Verbose -Message ("$([DateTime]::Now.ToShortTimeString()) - Waiting " + `
                                            "for distributed cache to start on all servers " + `
                                            "(waited $count of $maxCount minutes)")
                    Start-Sleep -Seconds 60
                    $serviceCheck = Get-SPServiceInstance | Where-Object -FilterScript {
                        $_.GetType().Name -eq "SPDistributedCacheServiceInstance" -and `
                        $_.Status -ne "Online"
                    }
                    $count++
                }
            }
        }
    }
    else
    {
        Write-Verbose -Message "Removing distributed cache to the server"
        Invoke-SPDSCCommand -Credential $InstallAccount -ScriptBlock {
            Remove-SPDistributedCacheServiceInstance

            $serviceInstance = Get-SPServiceInstance -Server $env:computername `
                | Where-Object -FilterScript {
                    $_.GetType().Name -eq "SPDistributedCacheServiceInstance"
            }

            if ($null -eq $serviceInstance)
            {
                $domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
                $currentServer = "$($env:computername).$domain"
                $serviceInstance = Get-SPServiceInstance -Server $currentServer `
                    | Where-Object -FilterScript {
                        $_.GetType().Name -eq "SPDistributedCacheServiceInstance"
                }
            }
            if ($null -ne $serviceInstance)
            {
                $serviceInstance.Delete()
            }
        }
        if ($CreateFirewallRules -eq $true)
        {
            Invoke-SPDSCCommand -Credential $InstallAccount -ScriptBlock {
                $firewallRule = Get-NetFirewallRule -DisplayName "SharePoint Distribute Cache" `
                                                    -ErrorAction SilentlyContinue
                if($null -ne $firewallRule)
                {
                    Write-Verbose -Message "Disabling firewall rules."
                    Disable-NetFirewallRule -DisplayName "SharePoint Distribute Cache"
                }
            }
        }
        Write-Verbose -Message "Distributed cache removed."
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $CacheSizeInMB,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAccount,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $CreateFirewallRules,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String[]]
        $ServerProvisionOrder,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing the cache host information"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq "Present")
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure", `
                                                         "CreateFirewallRules", `
                                                         "CacheSizeInMB")
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource
