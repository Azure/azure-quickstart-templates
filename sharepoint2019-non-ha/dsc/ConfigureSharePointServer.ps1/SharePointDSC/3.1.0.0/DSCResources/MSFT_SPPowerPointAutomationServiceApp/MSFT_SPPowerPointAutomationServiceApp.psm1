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
        $CacheExpirationPeriodInSeconds,

        [Parameter()]
        [System.UInt32]
        $MaximumConversionsPerWorker,

        [Parameter()]
        [System.UInt32]
        $WorkerKeepAliveTimeoutInSeconds,

        [Parameter()]
        [System.UInt32]
        $WorkerProcessCount,

        [Parameter()]
        [System.UInt32]
        $WorkerTimeoutInSeconds,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting PowerPoint Automation service app '$Name'"

    if(($ApplicationPool `
            -or $ProxyName `
            -or $CacheExpirationPeriodInSeconds `
            -or $MaximumConversionsPerWorker `
            -or $WorkerKeepAliveTimeoutInSeconds `
            -or $WorkerProcessCount `
            -or $WorkerTimeoutInSeconds) -and ($Ensure -eq "Absent"))
            {
                throw "You cannot use any of the parameters when Ensure is specified as Absent"
            }
    if (($Ensure -eq "Present") -and -not $ApplicationPool) 
    {
        throw ("An Application Pool is required to configure the PowerPoint " + `
               "Automation Service Application")
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        $serviceApps = Get-SPServiceApplication -Name $params.Name `
                                                -ErrorAction SilentlyContinue
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
            $_.GetType().FullName -eq "Microsoft.Office.Server.PowerPoint.Administration.PowerPointConversionServiceApplication"
        }     

        if ($null -eq $serviceApp) 
        {
            return $nullReturn  
        }

        $proxyName = ""
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

         $returnVal = @{
             Name = $serviceApp.DisplayName
             ProxyName = $proxyName
             ApplicationPool = $serviceApp.ApplicationPool.Name
             CacheExpirationPeriodInSeconds = $serviceApp.CacheExpirationPeriodInSeconds
             MaximumConversionsPerWorker = $serviceApp.MaximumConversionsPerWorker
             WorkerKeepAliveTimeoutInSeconds = $serviceApp.WorkerKeepAliveTimeoutInSeconds
             WorkerProcessCount = $serviceApp.WorkerProcessCount
             WorkerTimeoutInSeconds = $serviceApp.WorkerTimeoutInSeconds
             Ensure = "Present"
             InstallAccount = $params.InstallAccount
            
         }
         return $returnVal        
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
        $CacheExpirationPeriodInSeconds,

        [Parameter()]
        [System.UInt32]
        $MaximumConversionsPerWorker,

        [Parameter()]
        [System.UInt32]
        $WorkerKeepAliveTimeoutInSeconds,

        [Parameter()]
        [System.UInt32]
        $WorkerProcessCount,

        [Parameter()]
        [System.UInt32]
        $WorkerTimeoutInSeconds,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting PowerPoint Automation service app '$Name'" 

    if(($ApplicationPool `
            -or $ProxyName `
            -or $CacheExpirationPeriodInSeconds `
            -or $MaximumConversionsPerWorker `
            -or $WorkerKeepAliveTimeoutInSeconds `
            -or $WorkerProcessCount `
            -or $WorkerTimeoutInSeconds) -and ($Ensure -eq "Absent"))
            {
                throw "You cannot use any of the parameters when Ensure is specified as Absent"
            }
    if (($Ensure -eq "Present") -and -not $ApplicationPool) 
    {
        throw ("An Application Pool is required to configure the PowerPoint " + `
               "Automation Service Application")
    }

    $result = Get-TargetResource @PSBoundParameters
     if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present")
     {
        Write-Verbose -Message "Creating PowerPoint Automation Service Application $Name" 
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]

            $proxyName = $params.ProxyName
            if($null -eq $proxyName) 
            {
                $proxyName = "$($params.Name) Proxy"
            }
            
            $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool 
            if($appPool)
            {
                $serviceApp = New-SPPowerPointConversionServiceApplication -Name $params.Name -ApplicationPool $params.ApplicationPool
                $serviceAppProxy = New-SPPowerPointConversionServiceApplicationProxy -name $proxyName -ServiceApplication $serviceApp
            
                if($null -ne $params.CacheExpirationPeriodInSeconds)
                {
                    $serviceApp.CacheExpirationPeriodInSeconds = $params.CacheExpirationPeriodInSeconds
                }
                if($null -ne $params.MaximumConversionsPerWorker)
                {
                    $serviceApp.MaximumConversionsPerWorker = $params.MaximumConversionsPerWorker
                }
                if($null -ne $params.WorkerKeepAliveTimeoutInSeconds)
                {
                    $serviceApp.WorkerKeepAliveTimeoutInSeconds = $params.WorkerKeepAliveTimeoutInSeconds
                }
                if($null -ne $params.WorkerProcessCount)
                {
                    $serviceApp.WorkerProcessCount = $params.WorkerProcessCount
                }
                if($null -ne $params.WorkerTimeoutInSeconds)
                {
                    $serviceApp.WorkerTimeoutInSeconds = $params.WorkerTimeoutInSeconds
                }
                $serviceApp.Update();
            }   
            else 
            {
                throw "Specified application pool does not exist"
            } 
        }   
     }
     if ($result.Ensure -eq "Present" -and $Ensure -eq "Present")
     {
        Write-Verbose -Message "Updating PowerPoint Automation Service Application $Name" 
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters, $result `
                            -ScriptBlock {
            $params = $args[0]
            $result = $args[1]
            
            $serviceApps = Get-SPServiceApplication -Name $params.Name `
                                                    -ErrorAction SilentlyContinue
            if($null -eq $serviceApps)
            {
                throw "No Service applications are available in the farm."
            }
            $serviceApp = $serviceApps `
                | Where-Object -FilterScript {
                    $_.GetType().FullName -eq "Microsoft.Office.Server.PowerPoint.Administration.PowerPointConversionServiceApplication"
            }
            if($null -eq $serviceApp)
            {
                throw "Unable to find specified service application."
            }
            if ([string]::IsNullOrEmpty($params.ApplicationPool) -eq $false `
                -and $params.ApplicationPool -ne $result.ApplicationPool)
            {
                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool
                if($null -eq $appPool)
                {
                    throw "The specified App Pool does not exist"
                }
                $serviceApp.ApplicationPool = $appPool
            }
            if([string]::IsNullOrEmpty($params.ProxyName) -eq $false `
            -and $params.ProxyName -ne $result.ProxyName)
            {
                $proxies = Get-SPServiceApplicationProxy
                foreach($proxyInstance in $proxies)
                {
                    if($serviceApp.IsConnected($proxyInstance))
                    {
                        $proxyInstance.Delete()
                    }
                }   
                $serviceAppProxy = New-SPPowerPointConversionServiceApplicationProxy -Name $params.proxyName -ServiceApplication $serviceApp
            }
            if($null -ne $params.CacheExpirationPeriodInSeconds)
            {
                $serviceApp.CacheExpirationPeriodInSeconds = $params.CacheExpirationPeriodInSeconds
            }
            if($null -ne $params.MaximumConversionsPerWorker)
            {
                $serviceApp.MaximumConversionsPerWorker = $params.MaximumConversionsPerWorker
            }
            if($null -ne $params.WorkerKeepAliveTimeoutInSeconds)
            {
                $serviceApp.WorkerKeepAliveTimeoutInSeconds = $params.WorkerKeepAliveTimeoutInSeconds
            }
            if($null -ne $params.WorkerProcessCount)
            {
                $serviceApp.WorkerProcessCount = $params.WorkerProcessCount
            }
            if($null -ne $params.WorkerTimeoutInSeconds)
            {
                $serviceApp.WorkerTimeoutInSeconds = $params.WorkerTimeoutInSeconds
            }
                $serviceApp.Update();
        }
     }
     if($Ensure -eq "Absent")
     {
        Write-Verbose -Message "Removing PowerPoint Automation Service Application $Name" 
        Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0] 

            $serviceApps = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue
            if($null -eq $serviceApps)
            {
                return;
            }
            $serviceApp = $serviceApps | Where-Object -FilterScript {
                $_.GetType().FullName -eq "Microsoft.Office.Server.PowerPoint.Administration.PowerPointConversionServiceApplication"
            }
            if ($null -ne $serviceApp) 
            {
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
        $CacheExpirationPeriodInSeconds,

        [Parameter()]
        [System.UInt32]
        $MaximumConversionsPerWorker,

        [Parameter()]
        [System.UInt32]
        $WorkerKeepAliveTimeoutInSeconds,

        [Parameter()]
        [System.UInt32]
        $WorkerProcessCount,

        [Parameter()]
        [System.UInt32]
        $WorkerTimeoutInSeconds,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing PowerPoint Automation service app '$Name'" 
    if(($ApplicationPool `
            -or $ProxyName `
            -or $CacheExpirationPeriodInSeconds `
            -or $MaximumConversionsPerWorker `
            -or $WorkerKeepAliveTimeoutInSeconds `
            -or $WorkerProcessCount `
            -or $WorkerTimeoutInSeconds) -and ($Ensure -eq "Absent"))
            {
                throw "You cannot use any of the parameters when Ensure is specified as Absent"
            }
    if (($Ensure -eq "Present") -and -not $ApplicationPool) 
    {
        throw ("An Application Pool is required to configure the PowerPoint " + `
               "Automation Service Application")
    }
    $CurrentValues = Get-TargetResource @PSBoundParameters
    
    if($Ensure -eq "Absent")
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")                                     
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters
    }
}

Export-ModuleMember -Function *-TargetResource
