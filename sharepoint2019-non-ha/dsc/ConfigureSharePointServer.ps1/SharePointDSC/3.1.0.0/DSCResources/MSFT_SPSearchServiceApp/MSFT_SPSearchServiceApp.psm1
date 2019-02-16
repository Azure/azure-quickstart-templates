function Get-TargetResource
{
    # Ignoring this because we need to generate a stub credential to return up the current
    # crawl account as a PSCredential
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $SearchCenterUrl,

        [Parameter()]
        [System.Boolean]
        $CloudIndex,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DefaultContentAccessAccount,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $WindowsServiceAccount,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Search service application '$Name'"

    if ($PSBoundParameters.ContainsKey("WindowsServiceAccount"))
    {
        Write-Verbose -Message ("This parameter is deprecated in this resource. Please use " + `
                                "SPSearchServiceSettings instead.")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters, $PSScriptRoot) `
                                  -ScriptBlock {
        $params = $args[0]
        $scriptRoot = $args[1]

        Import-Module -Name (Join-Path $scriptRoot "MSFT_SPSearchServiceApp.psm1")

        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Administration")
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Office.Server.Search.Administration")
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Office.Server.Search")
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Office.Server")

        $serviceAppPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool `
                                                       -ErrorAction SilentlyContinue
        if ($null -eq $serviceAppPool)
        {
            Write-Verbose -Message ("Specified service application pool $($params.ApplicationPool) " + `
                                    "does not exist.")
        }

        $serviceApps = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue

        $nullReturn = @{
            Name = $params.Name
            ApplicationPool = $params.ApplicationPool
            Ensure = "Absent"
        }

        if ($null -eq $serviceApps)
        {
            return $nullReturn
        }
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.Office.Server.Search.Administration.SearchServiceApplication"
        }

        if ($null -eq $serviceApp)
        {
            return $nullReturn
        }
        else
        {
            $c = [Microsoft.Office.Server.Search.Administration.SearchContext]::GetContext($serviceApp.Name)
            $sc = New-Object -TypeName Microsoft.Office.Server.Search.Administration.Content `
                             -ArgumentList $c;
            $dummyPassword = ConvertTo-SecureString -String "-" -AsPlainText -Force
            if ($null -ne $sc.DefaultGatheringAccount)
            {
                $defaultAccount = New-Object -TypeName System.Management.Automation.PSCredential `
                                             -ArgumentList @($sc.DefaultGatheringAccount, $dummyPassword)
            }

            $cloudIndex = $false
            $version = Get-SPDSCInstalledProductVersion
            if(($version.FileMajorPart -gt 15) `
                -or ($version.FileMajorPart -eq 15 -and $version.FileBuildPart -ge 4745))
            {
                $cloudIndex = $serviceApp.CloudIndex
            }

            $serviceAppProxies = Get-SPServiceApplicationProxy -ErrorAction SilentlyContinue
            if ($null -ne $serviceAppProxies)
            {
                $serviceAppProxy = $serviceAppProxies | Where-Object -FilterScript {
                    $serviceApp.IsConnected($_)
                }
                if ($null -ne $serviceAppProxy)
                {
                    $pName = $serviceAppProxy.Name
                }
            }

            $returnVal =  @{
                Name                        = $serviceApp.DisplayName
                ProxyName                   = $pName
                ApplicationPool             = $serviceApp.ApplicationPool.Name
                DatabaseName                = $serviceApp.SearchAdminDatabase.Name
                DatabaseServer              = $serviceApp.SearchAdminDatabase.NormalizedDataSource
                Ensure                      = "Present"
                SearchCenterUrl             = $serviceApp.SearchCenterUrl
                DefaultContentAccessAccount = $defaultAccount
                CloudIndex                  = $cloudIndex
                WindowsServiceAccount       = $params.WindowsServiceAccount
                InstallAccount              = $params.InstallAccount
            }
            return $returnVal
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $SearchCenterUrl,

        [Parameter()]
        [System.Boolean]
        $CloudIndex,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DefaultContentAccessAccount,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $WindowsServiceAccount,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Search service application '$Name'"

    if ($PSBoundParameters.ContainsKey("WindowsServiceAccount"))
    {
        Write-Verbose -Message ("This parameter is deprecated in this resource. Please use " + `
                                "SPSearchServiceSettings instead.")
    }

    $result = Get-TargetResource @PSBoundParameters

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present")
    {
        # Create the service app as it doesn't exist

        Write-Verbose -Message "Creating Search Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0]

            $serviceAppPool = Get-SPServiceApplicationPool $params.ApplicationPool
            if ($null -eq $serviceAppPool)
            {
                throw ("Specified service application pool $($params.ApplicationPool) does not " + `
                       "exist. Please make sure it exists before continuing.")
            }

            $serviceInstance = Get-SPEnterpriseSearchServiceInstance -Local
            Start-SPEnterpriseSearchServiceInstance -Identity $serviceInstance `
                                                    -ErrorAction SilentlyContinue
            $newParams = @{
                Name = $params.Name
                ApplicationPool = $params.ApplicationPool
            }
            if ($params.ContainsKey("DatabaseServer") -eq $true)
            {
                $newParams.Add("DatabaseServer", $params.DatabaseServer)
            }
            if ($params.ContainsKey("DatabaseName") -eq $true)
            {
                $newParams.Add("DatabaseName", $params.DatabaseName)
            }

            if ($params.ContainsKey("CloudIndex") -eq $true -and $params.CloudIndex -eq $true)
            {
                $version = Get-SPDSCInstalledProductVersion
                if (($version.FileMajorPart -gt 15) `
                    -or ($version.FileMajorPart -eq 15 -and $version.FileBuildPart -ge 4745))
                {
                    $newParams.Add("CloudIndex", $params.CloudIndex)
                }
                else
                {
                    throw ("Please install SharePoint 2019, 2016 or SharePoint 2013 with August " + `
                           "2015 CU or higher before attempting to create a cloud enabled " + `
                           "search service application")
                }
            }

            $app = New-SPEnterpriseSearchServiceApplication @newParams
            if ($app)
            {
                if ($null -eq $params.ProxyName)
                {
                    $pName = "$($params.Name) Proxy"
                }
                else
                {
                    $pName = $params.ProxyName
                }

                Write-Verbose -Message "Creating proxy with name $pName"
                New-SPEnterpriseSearchServiceApplicationProxy -Name $pName -SearchApplication $app

                if ($params.ContainsKey("DefaultContentAccessAccount") -eq $true)
                {
                    Write-Verbose -Message ("Setting DefaultContentAccessAccount to " + `
                                            $params.DefaultContentAccessAccount.UserName)
                    $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool
                    $account = $params.DefaultContentAccessAccount
                    $setParams = @{
                        ApplicationPool = $appPool
                        Identity = $app
                        DefaultContentAccessAccountName = $account.UserName
                        DefaultContentAccessAccountPassword = $account.Password
                    }
                    Set-SPEnterpriseSearchServiceApplication @setParams
                }

                if ($params.ContainsKey("SearchCenterUrl") -eq $true)
                {
                    Write-Verbose -Message "Setting SearchCenterUrl to $($params.SearchCenterUrl)"
                    $serviceApp = Get-SPServiceApplication -Name $params.Name | `
                        Where-Object -FilterScript {
                            $_.GetType().FullName -eq "Microsoft.Office.Server.Search.Administration.SearchServiceApplication"
                        }
                    $serviceApp.SearchCenterUrl = $params.SearchCenterUrl
                    $serviceApp.Update()
                }
            }
        }
    }

    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present")
    {
        # Update the service app that already exists
        Write-Verbose -Message "Updating Search Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments @($PSBoundParameters, $result) `
                            -ScriptBlock {
            $params = $args[0]
            $result = $args[1]

            $serviceApp = Get-SPServiceApplication -Name $params.Name | `
                Where-Object -FilterScript {
                    $_.GetType().FullName -eq "Microsoft.Office.Server.Search.Administration.SearchServiceApplication"
                }

            if ($null -eq $params.ProxyName)
            {
                $pName = "$($params.Name) Proxy"
            }
            else
            {
                $pName = $params.ProxyName
            }

            if ($result.ProxyName -ne $pName)
            {
                if ($null -eq $result.ProxyName)
                {
                    Write-Verbose -Message "Creating proxy with name $pName"
                    New-SPEnterpriseSearchServiceApplicationProxy -Name $pName -SearchApplication $serviceApp
                }
                else
                {
                    Write-Verbose -Message "Updating proxy name to $pName"
                    $serviceAppProxy = Get-SPServiceApplicationProxy | Where-Object -FilterScript {
                                           $_.Name -eq $result.ProxyName
                                       }
                    $serviceAppProxy.Name = $pName
                    $serviceAppProxy.Update()
                }
            }

            $setParams = @{
                Identity = $serviceApp
            }

            if ($result.ApplicationPool -ne $params.ApplicationPool)
            {
                Write-Verbose -Message "Updating ApplicationPool to $($params.ApplicationPool)"

                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool
                $setParams.Add("ApplicationPool", $appPool)
            }

            if ($params.ContainsKey("DefaultContentAccessAccount") -eq $true -and `
                $result.DefaultContentAccessAccount.UserName -ne $params.DefaultContentAccessAccount.UserName)
            {
                Write-Verbose -Message ("Updating DefaultContentAccessAccount to " + `
                                        $params.DefaultContentAccessAccount.UserName)

                $account = $params.DefaultContentAccessAccount
                $setParams.Add("DefaultContentAccessAccountName", $account.UserName)
                $setParams.Add("DefaultContentAccessAccountPassword", $account.Password)
            }

            if ($setParams.Count -gt 1)
            {
                Set-SPEnterpriseSearchServiceApplication @setParams
            }

            if ($params.ContainsKey("SearchCenterUrl") -eq $true -and `
                $result.SearchCenterUrl -ne $params.SearchCenterUrl)
            {
                Write-Verbose -Message "Updating SearchCenterUrl to $($params.SearchCenterUrl)"
                $serviceApp = Get-SPServiceApplication -Name $params.Name | `
                    Where-Object -FilterScript {
                        $_.GetType().FullName -eq "Microsoft.Office.Server.Search.Administration.SearchServiceApplication"
                    }
                $serviceApp.SearchCenterUrl = $params.SearchCenterUrl
                $serviceApp.Update()
            }
        }
    }

    if ($Ensure -eq "Absent")
    {
        # The service app should not exit
        Write-Verbose -Message "Removing Search Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $serviceApp =  Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.Office.Server.Search.Administration.SearchServiceApplication"

            }

            $proxies = Get-SPServiceApplicationProxy
            foreach($proxyInstance in $proxies)
            {
                if($serviceApp.IsConnected($proxyInstance))
                {
                    $proxyInstance.Delete()
                }
            }

            Remove-SPServiceApplication -Identity $serviceApp -Confirm:$false
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $SearchCenterUrl,

        [Parameter()]
        [System.Boolean]
        $CloudIndex,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DefaultContentAccessAccount,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $WindowsServiceAccount,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Search service application '$Name'"

    if ($PSBoundParameters.ContainsKey("WindowsServiceAccount"))
    {
        Write-Verbose -Message ("This parameter is deprecated in this resource. Please use " + `
                                "SPSearchServiceSettings instead.")
    }

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($PSBoundParameters.ContainsKey("DefaultContentAccessAccount") `
        -and $Ensure -eq "Present")
    {
        $desired = $DefaultContentAccessAccount.UserName
        $current = $CurrentValues.DefaultContentAccessAccount.UserName

        if ($desired -ne $current)
        {
            Write-Verbose -Message "Default content access account is different, returning false"
            Write-Verbose -Message "Desired: $desired. Current: $current."
            return $false
        }
    }

    if ($Ensure -eq "Present")
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure",
                                                         "ApplicationPool",
                                                         "SearchCenterUrl",
                                                         "ProxyName")
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")
    }
}

Export-ModuleMember -Function *-TargetResource
