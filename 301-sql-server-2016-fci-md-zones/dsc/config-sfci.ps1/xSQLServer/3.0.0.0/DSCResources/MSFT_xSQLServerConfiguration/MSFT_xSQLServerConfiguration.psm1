$dom = [System.AppDomain]::CreateDomain("xSQLServerConfiguration")

Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [parameter(Mandatory = $true)]
        [System.String]
        $OptionName,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $OptionValue,

        [System.Boolean]
        $RestartService = $false
    )

    $sqlServer = Get-SqlServerObject -InstanceName $InstanceName
    $option = $sqlServer.Configuration.Properties | where {$_.DisplayName -eq $optionName}
    if(!$option)
    {
        throw "Specified option '$OptionName' was not found!"
    }

    $returnValue = @{
        InstanceName   = $InstanceName
        OptionName     = $option.DisplayName
        OptionValue    = $option.ConfigValue
        RestartService = $RestartService
    }

    return $returnValue
}

Function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [parameter(Mandatory = $true)]
        [System.String]
        $OptionName,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $OptionValue,

        [System.Boolean]
        $RestartService = $false
    )

    $sqlServer = Get-SqlServerObject -InstanceName $InstanceName

    $option = $sqlServer.Configuration.Properties | where {$_.DisplayName -eq $optionName}

    if(!$option)
    {
        throw "Specified option '$OptionName' was not found!"
    }

    $option.ConfigValue = $OptionValue
    $sqlServer.Configuration.Alter()
    if ($option.IsDynamic -eq $true)
    {  
        Write-Verbose "Configuration option has been updated."
    }
    elseif ($option.IsDynamic -eq $false -and $RestartService -eq $true)
    {
        Write-Verbose "Configuration option has been updated ..."

        Restart-SqlServer -InstanceName $InstanceName
    }
    else
    {
        Write-Warning "Configuration option was set but SQL Server restart is required."
    }
}

Function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [parameter(Mandatory = $true)]
        [System.String]
        $OptionName,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $OptionValue,

        [System.Boolean]
        $RestartService = $false
    )

    $state = Get-TargetResource -InstanceName $InstanceName -OptionName $OptionName -OptionValue $OptionValue

    return ($state.OptionValue -eq $OptionValue)
}

#region helper functions
Function Get-SqlServerMajorVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $instanceId = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL").$InstanceName
    $sqlVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\Setup").Version
    $sqlMajorVersion = $sqlVersion.Split(".")[0]
    if (!$sqlMajorVersion)
    {
        throw "Unable to detect version for sql server instance: $InstanceName!"
    }
    return $sqlMajorVersion
}

Function Get-SqlServerObject
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    if($InstanceName -eq "MSSQLSERVER")
    {
        $connectSQL = $env:COMPUTERNAME
    }
    else
    {
        $connectSQL = "$($env:COMPUTERNAME)\$InstanceName"
    }

    $sqlMajorVersion = Get-SqlServerMajorVersion -InstanceName $InstanceName
    $smo = $dom.Load("Microsoft.SqlServer.Smo, Version=$sqlMajorVersion.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
    Write-Verbose "Loaded assembly: $($smo.FullName)"

    $sqlServer = new-object $smo.GetType("Microsoft.SqlServer.Management.Smo.Server") $connectSQL

    if(!$sqlServer)
    {
        throw "Unable to connect to sql instance: $InstanceName"
    }

    return $sqlServer
}

Function Restart-SqlServer
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $sqlMajorVersion = Get-SqlServerMajorVersion -InstanceName $InstanceName
    $sqlWmiManagement = $dom.Load("Microsoft.SqlServer.SqlWmiManagement, Version=$sqlMajorVersion.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
    Write-Verbose "Loaded assembly: $($sqlWmiManagement.FullName)"
    $wmi = new-object $sqlWmiManagement.GetType("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer")

    if(!$wmi)
    {
        throw "Unable to create wmi ManagedComputer object for sql instance: $InstanceName"
    }

    Write-Verbose "SQL Service will be restarted ..."
    if($InstanceName -eq "MSSQLSERVER")
    {
        $dbServiceName = "MSSQLSERVER"
        $agtServiceName = "SQLSERVERAGENT"
    }
    else
    {
        $dbServiceName = "MSSQL`$$InstanceName"
        $agtServiceName = "SQLAgent`$$InstanceName"
    }

    $sqlService = $wmi.Services[$dbServiceName]
    $agentService = $wmi.Services[$agtServiceName]
    $startAgent = ($agentService.ServiceState -eq "Running")

    if ($sqlService -eq $null)
    {
        throw "$dbServiceName service was not found, restart service failed"
    }

    Write-Verbose "Stopping [$dbServiceName] service ..."
    $sqlService.Stop()
    Wait-SqlServiceState -Service $sqlService -State "Stopped" 

    Write-Verbose "Starting [$dbServiceName] service ..."
    $sqlService.Start()
    Wait-SqlServiceState -Service $sqlService -State "Running"

    if ($startAgent)
    {
        Write-Verbose "Starting [$agtServiceName] service ..."
        $agentService.Start()
        Wait-SqlServiceState -Service $agentService -State "Running"
    }
}

function Wait-SqlServiceState
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Service,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $State,
        
        [System.Int32]
        $TimeOut = 60
    )
    
    $startTime = Get-Date
    
    while($Service.ServiceState -ne $State)
    {
        if((New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds -gt $TimeOut)
        {
            throw "Time out of $TimeOut seconds exceeded while waiting for service [$($Service.DisplayName)] to enter '$State' state!"
        }
        
        Start-Sleep -Milliseconds 500
        $Service.Refresh()
    }
    
    Write-Verbose "[$($Service.DisplayName)] service is $State"
}
#endregion

Export-ModuleMember -Function *-TargetResource
