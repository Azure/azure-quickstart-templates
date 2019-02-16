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

    Write-Verbose -Message "Getting for PerformancePoint Service Application '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        $serviceApps = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue
        $nullReturn = @{
            Name = $params.Name
            ApplicationPool = $params.ApplicationPool
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        } 
        if ($null -eq $serviceApps) 
        {
            return $nullReturn 
        }
        $serviceApp = $serviceApps | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.PerformancePoint.Scorecards.BIMonitoringServiceApplication"
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
                Name            = $serviceApp.DisplayName
                ProxyName       = $proxyName
                ApplicationPool = $serviceApp.ApplicationPool.Name
                DatabaseName    = $serviceApp.Database.Name
                DatabaseServer  = $serviceApp.Database.NormalizedDataSource
                Ensure          = "Present"
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

    Write-Verbose -Message "Setting PerformancePoint Service Application '$Name'"

    $result = Get-TargetResource @PSBoundParameters

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Creating PerformancePoint Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $newParams = @{
                Name = $params.Name
                ApplicationPool = $params.ApplicationPool
            }
            if ($params.ContainsKey("DatabaseName") -eq $true) 
            {
                $newParams.Add("DatabaseName", $params.DatabaseName)
            }
            if ($params.ContainsKey("DatabaseServer") -eq $true) 
            {
                $newParams.Add("DatabaseServer", $params.DatabaseServer)
            }
        
            New-SPPerformancePointServiceApplication @newParams
            if ($null -eq $params.ProxyName) 
            {
                $pName = "$($params.Name) Proxy"
            } 
            else 
            {
                $pName = $params.ProxyName
            }
            New-SPPerformancePointServiceApplicationProxy -Name $pName `
                                                          -ServiceApplication $params.Name `
                                                          -Default
        }
    }

    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present") 
    {
        if ($ApplicationPool -ne $result.ApplicationPool) 
        {
            Write-Verbose -Message "Updating PerformancePoint Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount `
                                -Arguments $PSBoundParameters `
                                -ScriptBlock {
                $params = $args[0]               

                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool

                Get-SPServiceApplication -Name $params.Name `
                    | Where-Object -FilterScript {
                        $_.GetType().FullName -eq "Microsoft.PerformancePoint.Scorecards.BIMonitoringServiceApplication"
                    } | Set-SPPerformancePointServiceApplication -ApplicationPool $appPool
            }
        }
    }
    if ($Ensure -eq "Absent") 
    {
        Write-Verbose -Message "Removing PerformancePoint Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $app = Get-SPServiceApplication -Name $params.Name | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.PerformancePoint.Scorecards.BIMonitoringServiceApplication"
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
    
    Write-Verbose -Message "Testing PerformancePoint Service Application '$Name'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("ApplicationPool", "Ensure")
}

Export-ModuleMember -Function *-TargetResource
