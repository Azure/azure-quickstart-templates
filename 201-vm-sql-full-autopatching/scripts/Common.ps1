#Verify if enable SQL Server firewall rules are required
function Set-SqlFirewallRule([string]$ConnectionType)
{
    $ConnectionType = $ConnectionType.ToUpper()

    if($ConnectionType -eq "LOCAL")
    {
        return $false
    }

    return $true
}

#Return a SMO object to a SQL Server instance using the provided credentials
function Get-SqlServer([string]$InstanceName, [PSCredential]$Credential)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    $sc = New-Object Microsoft.SqlServer.Management.Common.ServerConnection

    $list = $InstanceName.Split("\")
    if ($list.Count -gt 1 -and $list[1] -eq "MSSQLSERVER")
    {
        $sc.ServerInstance = $list[0]
    }
    else
    {
        $sc.ServerInstance = "."
    }

    $sc.ConnectAsUser = $true
    if ($Credential.GetNetworkCredential().Domain -and $Credential.GetNetworkCredential().Domain -ne $env:COMPUTERNAME)
    {
        $sc.ConnectAsUserName = "$($Credential.GetNetworkCredential().UserName)@$($Credential.GetNetworkCredential().Domain)"
    }
    else
    {
        $sc.ConnectAsUserName = $Credential.GetNetworkCredential().UserName
    }
    $sc.ConnectAsUserPassword = $Credential.GetNetworkCredential().Password
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    $s = New-Object Microsoft.SqlServer.Management.Smo.Server $sc

    $s
}

#Sets the sql server object log and data paths folders if required and return the final operation result
function Set-SqlServerFolders([string]$FilePath, [string]$LogPath, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    $result = $false

    $bCheck = $Server.DefaultFile.TrimEnd("\") -eq $FilePath.TrimEnd("\")
    
    if ($FilePath -and !$bCheck)
    {
        Write-Verbose -Message "The server default file path is NOT '$($FilePath)' ..."
        [System.IO.Directory]::CreateDirectory($FilePath) | Out-Null
        $Server.Settings.DefaultFile = $FilePath
        $Server.Settings.Alter()
    }
    else
    {
        $result = $true
    }

    $bCheck = $Server.DefaultLog.TrimEnd("\") -eq $LogPath.TrimEnd("\")

    if ($LogPath -and !$bCheck)
    {
        Write-Verbose -Message "The server default log path is NOT '$($LogPath)' ..."
        [System.IO.Directory]::CreateDirectory($LogPath) | Out-Null
        $Server.Settings.DefaultLog = $LogPath
        $Server.Settings.Alter()
    }
    else
    {
       $result = $result -and $true
    }

    return $result
}

# Restart SQL Server instance and wait for until start is completed.
function Restart-SqlServer([string]$InstanceName, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
    $mc = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $Server.Name
    $list = $InstanceName.Split("\")
    if ($list.Count -gt 1)
    {
        $InstanceName = $list[1]
    }
    else
    {
        $InstanceName = "MSSQLSERVER"
    }
    $svc = $mc.Services[$InstanceName]

    Write-Verbose -Message "Restarting SQL server instance '$($InstanceName)' ..."
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.WmiEnum") | Out-Null
    $svc.Stop()
    $svc.Refresh()
    while ($svc.ServiceState -ne [Microsoft.SqlServer.Management.Smo.Wmi.ServiceState]::Stopped)
    {
        $svc.Refresh()
    }

    $svc.Start()
    $svc.Refresh()
    while ($svc.ServiceState -ne [Microsoft.SqlServer.Management.Smo.Wmi.ServiceState]::Running)
    {
        $svc.Refresh()
    }
}

function Set-ServerMixedMode([Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    $Server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed

    # Make the changes
    $Server.Alter()
}
