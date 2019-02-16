function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter()]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenEwsSyncSubscriptionSearches,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenProviderRefreshes,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenSearchQueries,

        [Parameter()]
        [System.UInt32]
        $NumberOfSubscriptionSyncsPerEwsSyncRun,

        [Parameter()]
        [System.UInt32]
        $NumberOfUsersEwsSyncWillProcessAtOnce,

        [Parameter()]
        [System.UInt32]
        $NumberOfUsersPerEwsSyncBatch,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Work management service app '$Name'"

    $installedVersion = Get-SPDSCInstalledProductVersion
    if ($installedVersion.FileMajorPart -eq 16)
    {
        throw [Exception] ("Work Management Service Application is no longer available " + `
                           "in SharePoint 2016/2019: " + `
                           "https://technet.microsoft.com/en-us/library/mt346112(v=office.16).aspx")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $serviceApps = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue

        $nullReturn = @{
            Name            = $params.Name
            Ensure          = "Absent"
            ApplicationPool = $params.ApplicationPool
        }

        if ($null -eq $serviceApps)
        {
            return $nullReturn
        }
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.Office.Server.WorkManagement.WorkManagementServiceApplication"
        }

        if ($null -eq $serviceApp)
        {
            return $nullReturn
        }
        else
        {
            $serviceAppProxies = Get-SPServiceApplicationProxy -ErrorAction SilentlyContinue
            if ($null -ne $serviceAppProxies)
            {
                $serviceAppProxy = $serviceAppProxies | Where-Object -FilterScript {
                    $serviceApp.IsConnected($_)
                }
                if ($null -ne $serviceAppProxy)
                {
                    $proxyName = $serviceAppProxy.Name
                }
            }

            return @{
                Name                                          = $serviceApp.DisplayName
                ProxyName                                     = $proxyName
                ApplicationPool                               = $serviceApp.ApplicationPool.Name
                MinimumTimeBetweenEwsSyncSubscriptionSearches = $serviceApp.AdminSettings.MinimumTimeBetweenEwsSyncSubscriptionSearches.TotalMinutes
                MinimumTimeBetweenProviderRefreshes           = $serviceApp.AdminSettings.MinimumTimeBetweenProviderRefreshes.TotalMinutes
                MinimumTimeBetweenSearchQueries               = $serviceApp.AdminSettings.MinimumTimeBetweenProviderRefreshes.TotalMinutes
                NumberOfSubscriptionSyncsPerEwsSyncRun        = $serviceApp.AdminSettings.NumberOfSubscriptionSyncsPerEwsSyncRun
                NumberOfUsersEwsSyncWillProcessAtOnce         = $serviceApp.AdminSettings.NumberOfUsersEwsSyncWillProcessAtOnce
                NumberOfUsersPerEwsSyncBatch                  = $serviceApp.AdminSettings.NumberOfUsersPerEwsSyncBatch
                Ensure                                        = "Present"
            }
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

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter()]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenEwsSyncSubscriptionSearches,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenProviderRefreshes,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenSearchQueries,

        [Parameter()]
        [System.UInt32]
        $NumberOfSubscriptionSyncsPerEwsSyncRun,

        [Parameter()]
        [System.UInt32]
        $NumberOfUsersEwsSyncWillProcessAtOnce,

        [Parameter()]
        [System.UInt32]
        $NumberOfUsersPerEwsSyncBatch,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Work management service app '$Name'"
    $PSBoundParameters.Ensure = $Ensure

    $installedVersion = Get-SPDSCInstalledProductVersion
    if ($installedVersion.FileMajorPart -eq 16)
    {
        throw [Exception] ("Work Management Service Application is no longer available " + `
                           "in SharePoint 2016/2019: " + `
                           "https://technet.microsoft.com/en-us/library/mt346112(v=office.16).aspx")
    }

    if ($Ensure -ne "Absent" -and $PSBoundParameters.ContainsKey("ApplicationPool") -eq $false)
    {
        throw "Parameter ApplicationPool is required unless service is being removed(Ensure='Absent')"
    }

    $result = Get-TargetResource @PSBoundParameters

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present")
    {
        Write-Verbose -Message "Creating work management Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            if ($params.ContainsKey("Ensure"))
            {
                $params.Remove("Ensure") | Out-Null
            }
            if ($params.ContainsKey("InstallAccount"))
            {
                $params.Remove("InstallAccount") | Out-Null
            }
            if ($params.ContainsKey("ProxyName"))
            {
                $pName = $params.ProxyName
                $params.Remove("ProxyName") | Out-Null
            }
            if ($null -eq $pName)
            {
                $pName = "$($params.Name) Proxy"
            }

            $app = New-SPWorkManagementServiceApplication @params
            if ($null -ne $app)
            {
                New-SPWorkManagementServiceApplicationProxy -Name $pName `
                                                            -ServiceApplication $app `
                                                            -DefaultProxyGroup
                Start-Sleep -Milliseconds 200
            }
        }
    }

    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present")
    {
        if ([string]::IsNullOrEmpty($ApplicationPool) -eq $false `
            -and $ApplicationPool -ne $result.ApplicationPool)
        {
            Write-Verbose -Message "Updating Application Pool of Work Management Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]

                $serviceApp = Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                    $_.GetType().FullName -eq "Microsoft.Office.Server.WorkManagement.WorkManagementServiceApplication"
                }
                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool
                Set-SPWorkManagementServiceApplication -Identity $serviceApp -ApplicationPool $appPool
            }
        }

        Write-Verbose -Message "Updating Application Pool of Work Management Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
            $params = $args[0]

            $setParams = @{}
            if ($params.ContainsKey("MinimumTimeBetweenEwsSyncSubscriptionSearches"))
            {
                $setParams.Add("MinimumTimeBetweenEwsSyncSubscriptionSearches",
                $params.MinimumTimeBetweenEwsSyncSubscriptionSearches)
            }
            if ($params.ContainsKey("MinimumTimeBetweenProviderRefreshes"))
            {
                $setParams.Add("MinimumTimeBetweenProviderRefreshes",
                $params.MinimumTimeBetweenProviderRefreshes)
            }
            if ($params.ContainsKey("MinimumTimeBetweenSearchQueries"))
            {
                $setParams.Add("MinimumTimeBetweenSearchQueries",
                $params.MinimumTimeBetweenSearchQueries)
            }
            if ($params.ContainsKey("NumberOfSubscriptionSyncsPerEwsSyncRun"))
            {
                $setParams.Add("NumberOfSubscriptionSyncsPerEwsSyncRun",
                $params.NumberOfSubscriptionSyncsPerEwsSyncRun)
            }
            if ($params.ContainsKey("NumberOfUsersEwsSyncWillProcessAtOnce"))
            {
                $setParams.Add("NumberOfUsersEwsSyncWillProcessAtOnce",
                $params.NumberOfUsersEwsSyncWillProcessAtOnce)
            }
            if ($params.ContainsKey("NumberOfUsersPerEwsSyncBatch"))
            {
                $setParams.Add("NumberOfUsersPerEwsSyncBatch",
                $params.NumberOfUsersPerEwsSyncBatch)
            }

            $setParams.Add("Name", $params.Name)
            $setParams.Add("ApplicationPool", $params.ApplicationPool)

            if ($setParams.ContainsKey("MinimumTimeBetweenEwsSyncSubscriptionSearches"))
            {
                $setParams.MinimumTimeBetweenEwsSyncSubscriptionSearches = New-TimeSpan -Days $setParams.MinimumTimeBetweenEwsSyncSubscriptionSearches
            }
            if ($setParams.ContainsKey("MinimumTimeBetweenProviderRefreshes"))
            {
                $setParams.MinimumTimeBetweenProviderRefreshes = New-TimeSpan -Days $setParams.MinimumTimeBetweenProviderRefreshes
            }
            if ($setParams.ContainsKey("MinimumTimeBetweenSearchQueries"))
            {
                $setParams.MinimumTimeBetweenSearchQueries = New-TimeSpan -Days $setParams.MinimumTimeBetweenSearchQueries
            }
            $setParams.Add("Confirm", $false)
            $appService =  Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.Office.Server.WorkManagement.WorkManagementServiceApplication"
            }

            $appService | Set-SPWorkManagementServiceApplication @setPArams | Out-Null
        }
    }

    if ($Ensure -eq "Absent")
    {
        # The service app should not exit
        Write-Verbose -Message "Removing Work Management Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $serviceApp = Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.Office.Server.WorkManagement.WorkManagementServiceApplication"
            }

            $proxies = Get-SPServiceApplicationProxy
            foreach($proxyInstance in $proxies)
            {
                if($serviceApp.IsConnected($proxyInstance))
                {
                    $proxyInstance.Delete()
                }
            }

            Remove-SPServiceApplication $serviceApp -Confirm:$false
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
        $Name,

        [Parameter()]
        [System.String]
        $ProxyName,

        [Parameter()]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenEwsSyncSubscriptionSearches,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenProviderRefreshes,

        [Parameter()]
        [System.UInt32]
        $MinimumTimeBetweenSearchQueries,

        [Parameter()]
        [System.UInt32]
        $NumberOfSubscriptionSyncsPerEwsSyncRun,

        [Parameter()]
        [System.UInt32]
        $NumberOfUsersEwsSyncWillProcessAtOnce,

        [Parameter()]
        [System.UInt32]
        $NumberOfUsersPerEwsSyncBatch,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Work management service app '$Name'"

    $installedVersion = Get-SPDSCInstalledProductVersion
    if ($installedVersion.FileMajorPart -eq 16)
    {
        throw [Exception] ("Work Management Service Application is no longer available " + `
                           "in SharePoint 2016/2019: " + `
                           "https://technet.microsoft.com/en-us/library/mt346112(v=office.16).aspx")
    }

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq "Present")
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("ApplicationPool",
                                                         "MinimumTimeBetweenEwsSyncSubscriptionSearches",
                                                         "MinimumTimeBetweenProviderRefreshes",
                                                         "MinimumTimeBetweenSearchQueries",
                                                         "Name",
                                                         "NumberOfSubscriptionSyncsPerEwsSyncRun",
                                                         "NumberOfUsersEwsSyncWillProcessAtOnce",
                                                         "NumberOfUsersPerEwsSyncBatch",
                                                         "Ensure")
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource

