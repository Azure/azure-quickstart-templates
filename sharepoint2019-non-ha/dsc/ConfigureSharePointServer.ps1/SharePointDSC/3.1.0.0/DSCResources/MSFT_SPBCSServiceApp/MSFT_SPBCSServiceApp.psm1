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

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApplicationPool,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting BCS service app '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $serviceApps = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name = $params.Name
            ApplicationPool = $params.ApplicationPool
            DatabaseName = $null
            DatabaseServer = $null
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        }
        if ($null -eq $serviceApps)
        {
            return $nullReturn
        }
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.SharePoint.BusinessData.SharedService.BdcServiceApplication"
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

            $returnVal =  @{
                Name = $serviceApp.DisplayName
                ProxyName = $proxyName
                ApplicationPool = $serviceApp.ApplicationPool.Name
                DatabaseName = $serviceApp.Database.Name
                DatabaseServer = $serviceApp.Database.NormalizedDataSource
                Ensure = "Present"
                InstallAccount = $params.InstallAccount
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
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting BCS service app '$Name'"

    if ($Ensure -eq "Present" -and
        ($PSBoundParameters.ContainsKey("DatabaseName") -eq $false -or
        $PSBoundParameters.ContainsKey("DatabaseServer") -eq $false))
    {
        Throw "Parameter DatabaseName and DatabaseServer are required when Ensure=Present"
    }

    $result = Get-TargetResource @PSBoundParameters

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present")
    {
        # The service app doesn't exist but should
        Write-Verbose -Message "Creating BCS Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $bcsServiceApp = New-SPBusinessDataCatalogServiceApplication -Name $params.Name `
                                                                         -ApplicationPool $params.ApplicationPool `
                                                                         -DatabaseName $params.DatabaseName `
                                                                         -DatabaseServer $params.DatabaseServer

            if ($params.ContainsKey("ProxyName"))
            {
                # The New-SPBusinessDataCatalogServiceApplication cmdlet creates a proxy by default
                # If a name is specified, we first need to delete the created one
                $proxies = Get-SPServiceApplicationProxy
                foreach($proxyInstance in $proxies)
                {
                    if($bcsServiceApp.IsConnected($proxyInstance))
                    {
                        $proxyInstance.Delete()
                    }
                }

                New-SPBusinessDataCatalogServiceApplicationProxy -Name $params.ProxyName `
                                                                 -ServiceApplication $bcsServiceApp | Out-Null
            }
        }
    }

    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present")
    {
        # The service app exists but has the wrong application pool
        if ($ApplicationPool -ne $result.ApplicationPool)
        {
            Write-Verbose -Message "Updating BCS Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]

                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool

                Get-SPServiceApplication -Name $params.Name `
                    | Where-Object -FilterScript {
                        $_.GetType().FullName -eq "Microsoft.SharePoint.BusinessData.SharedService.BdcServiceApplication"
                    } `
                    | Set-SPBusinessDataCatalogServiceApplication -ApplicationPool $appPool
            }
        }
    }

    if ($Ensure -eq "Absent")
    {
        # The service app should not exit
        Write-Verbose -Message "Removing BCS Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $app = Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.SharePoint.BusinessData.SharedService.BdcServiceApplication"
            }

            $proxies = Get-SPServiceApplicationProxy
            foreach($proxyInstance in $proxies)
            {
                if($app.IsConnected($proxyInstance))
                {
                    $proxyInstance.Delete()
                }
            }

            Remove-SPServiceApplication -Identity $app -Confirm:$false
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
        $DatabaseName,

        [Parameter()]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing BCS service app '$Name'"

    $PSBoundParameters.Ensure = $Ensure

    return Test-SPDscParameterState -CurrentValues (Get-TargetResource @PSBoundParameters) `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("ApplicationPool", "Ensure")
}

Export-ModuleMember -Function *-TargetResource
