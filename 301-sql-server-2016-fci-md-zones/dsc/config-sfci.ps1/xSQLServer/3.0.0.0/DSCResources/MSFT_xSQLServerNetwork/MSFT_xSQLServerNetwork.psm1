Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        # for now support is just for tcp protocol
        # possible future feature to support additional protocols
        [parameter(Mandatory = $true)]
        [ValidateSet("tcp")]
        [System.String]
        $ProtocolName
    )

    Write-Verbose "xSQLServerNetwork.Get-TargetResourece ..."
    Write-Verbose "Parameters: InstanceName = $InstanceName; ProtocolName = $ProtocolName"

    # create isolated appdomain to load version specific libs, this needed if you have multiple versions of SQL server in the same configuration
    $dom_get = [System.AppDomain]::CreateDomain("xSQLServerNetwork_Get_$InstanceName")

    Try
    {
        $version = GetVersion -InstanceName $InstanceName

        if([string]::IsNullOrEmpty($version))
        {
            throw "Unable to resolve SQL version for instance"
        }
        
        $smo = $dom_get.Load("Microsoft.SqlServer.Smo, Version=$version.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
        $sqlWmiManagement = $dom_get.Load("Microsoft.SqlServer.SqlWmiManagement, Version=$version.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")

        Write-Verbose "Creating [Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer] object"
        $wmi = new-object $sqlWmiManagement.GetType("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer")

        Write-Verbose "Getting [$ProtocolName] network protocol for [$InstanceName] SQL instance"
        $tcp = $wmi.ServerInstances[$InstanceName].ServerProtocols[$ProtocolName]

        Write-Verbose "Reading state values:"
        $returnValue = @{
            InstanceName = $InstanceName
            ProtocolName = $ProtocolName
            IsEnabled = $tcp.IsEnabled
            TCPDynamicPorts = $tcp.IPAddresses["IPAll"].IPAddressProperties["TcpDynamicPorts"].Value
            TCPPort = $tcp.IPAddresses["IPAll"].IPAddressProperties["TcpPort"].Value
        }

        $returnValue.Keys | % { Write-Verbose "$_ = $($returnValue[$_])" }

    }
    Finally
    {
        [System.AppDomain]::Unload($dom_get)
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
        [ValidateSet("tcp")]
        [System.String]
        $ProtocolName,

        [System.Boolean]
        $IsEnabled,

        [ValidateSet("0")]
        [System.String]
        $TCPDynamicPorts,

        [System.String]
        $TCPPort,

        [System.Boolean]
        $RestartService = $false
    )

    Write-Verbose "xSQLServerNetwork.Set-TargetResource ..."
    Write-Verbose "Parameters: InstanceName = $InstanceName; ProtocolName = $ProtocolName; IsEnabled=$IsEnabled; TCPDynamicPorts = $TCPDynamicPorts; TCPPort = $TCPPort; RestartService=$RestartService;"

    Write-Verbose "Calling xSQLServerNetwork.Get-TargetResource ..."
    $currentState = Get-TargetResource -InstanceName $InstanceName -ProtocolName $ProtocolName

    # create isolated appdomain to load version specific libs, this needed if you have multiple versions of SQL server in the same configuration
    $dom_set = [System.AppDomain]::CreateDomain("xSQLServerNetwork_Set_$InstanceName")

    Try
    {
        $version = GetVersion -InstanceName $InstanceName

        if([string]::IsNullOrEmpty($version))
        {
            throw "Unable to resolve SQL version for instance"
        }
        
        $smo = $dom_set.Load("Microsoft.SqlServer.Smo, Version=$version.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
        $sqlWmiManagement = $dom_set.Load("Microsoft.SqlServer.SqlWmiManagement, Version=$version.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")

        $desiredState = @{
            InstanceName = $InstanceName
            ProtocolName = $ProtocolName
            IsEnabled = $IsEnabled
            TCPDynamicPorts = $TCPDynamicPorts
            TCPPort = $TCPPort
        }

        Write-Verbose "Creating [Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer] object"
        $wmi = new-object $sqlWmiManagement.GetType("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer")

        Write-Verbose "Getting [$ProtocolName] network protocol for [$InstanceName] SQL instance"
        $tcp = $wmi.ServerInstances[$InstanceName].ServerProtocols[$ProtocolName]

        Write-Verbose "Checking [IsEnabled] property ..."
        if($desiredState["IsEnabled"] -ine $currentState["IsEnabled"])
        {
            Write-Verbose "Updating [IsEnabled] from $($currentState["IsEnabled"]) to $($desiredState["IsEnabled"])"
            $tcp.IsEnabled = $desiredState["IsEnabled"]
        }

        Write-Verbose "Checking [TCPDynamicPorts] property ..."
        if($desiredState["TCPDynamicPorts"] -ine $currentState["TCPDynamicPorts"])
        {
            Write-Verbose "Updating [TCPDynamicPorts] from $($currentState["TCPDynamicPorts"]) to $($desiredState["TCPDynamicPorts"])"
            $tcp.IPAddresses["IPAll"].IPAddressProperties["TcpDynamicPorts"].Value = $desiredState["TCPDynamicPorts"]
        }

        Write-Verbose "Checking [TCPPort property] ..."
        if($desiredState["TCPPort"] -ine $currentState["TCPPort"])
        {
            Write-Verbose "Updating [TCPPort] from $($currentState["TCPPort"]) to $($desiredState["TCPPort"])"
            $tcp.IPAddresses["IPAll"].IPAddressProperties["TcpPort"].Value = $desiredState["TCPPort"]
        }

        Write-Verbose "Saving changes ..."
        $tcp.Alter()

        if($RestartService)
        {
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

            while($sqlService.ServiceState -ne "Stopped")
            {
                Start-Sleep -Milliseconds 500
                $sqlService.Refresh()
            }
            Write-Verbose "[$dbServiceName] service stopped"

            Write-Verbose "Starting [$dbServiceName] service ..."
            $sqlService.Start()

            while($sqlService.ServiceState -ne "Running")
            {
                Start-Sleep -Milliseconds 500
                $sqlService.Refresh()
            }
            Write-Verbose "[$dbServiceName] service started"

            if ($startAgent)
            {
                Write-Verbose "Staring [$agtServiceName] service ..."
                $agentService.Start()
                while($agentService.ServiceState -ne "Running")
                {
                    Start-Sleep -Milliseconds 500
                    $agentService.Refresh()
                }
                Write-Verbose "[$agtServiceName] service started"
            }
        }
    }
    Finally
    {
        [System.AppDomain]::Unload($dom_set)
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
        [ValidateSet("tcp")]
        [System.String]
        $ProtocolName,

        [System.Boolean]
        $IsEnabled,

        [ValidateSet("0")]
        [System.String]
        $TCPDynamicPorts,

        [System.String]
        $TCPPort,

        [System.Boolean]
        $RestartService = $false
    )

    Write-Verbose "xSQLServerNetwork.Test-TargetResource ..."
    Write-Verbose "Parameters: InstanceName = $InstanceName; ProtocolName = $ProtocolName; IsEnabled=$IsEnabled; TCPDynamicPorts = $TCPDynamicPorts; TCPPort = $TCPPort; RestartService=$RestartService;"

    $desiredState = @{
        InstanceName = $InstanceName
        ProtocolName = $ProtocolName
        IsEnabled = $IsEnabled
        TCPDynamicPorts = $TCPDynamicPorts
        TCPPort = $TCPPort
    } 
    
    Write-Verbose "Calling xSQLServerNetwork.Get-TargetResource ..."
    $currentState = Get-TargetResource -InstanceName $InstanceName -ProtocolName $ProtocolName

    Write-Verbose "Comparing desiredState with currentSate ..."
    foreach($key in $desiredState.Keys)
    {
        if($currentState.Keys -eq $key)
        {
            if($desiredState[$key] -ine $currentState[$key] )
            {
                Write-Verbose "$key is different: desired = $($desiredState[$key]); current = $($currentState[$key])"
                return $false
            }
        }
        else
        {
            Write-Verbose "$key is missing"
            return $false
        }
    }

    Write-Verbose "States match"        
    return $true
}

Function GetVersion
{
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $instanceId = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL").$InstanceName
    $sqlVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\Setup").Version
    $sqlVersion.Split(".")[0]
}

Export-ModuleMember -Function *-TargetResource
