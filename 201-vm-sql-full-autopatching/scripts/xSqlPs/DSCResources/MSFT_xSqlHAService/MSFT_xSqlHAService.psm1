#
# xSQLService: DSC resource to enable Sql High Availability (HA) service on the given sql instance.
#


function RestartSqlServer()
{
    $list = Get-Service -Name MSSQL*

    foreach ($s in $list)
    {
        Set-Service -Name $s.Name -StartupType Automatic
        if ($s.Status -ne "Stopped")
        {
            $s.Stop()
            $s.WaitForStatus("Stopped")
            $s.Refresh()
        }
        if ($s.Status -ne "Running")
        {
            $s.Start()
            $s.WaitForStatus("Running")
            $s.Refresh()
        }
    }
}

function IsSQLLogin($SqlInstance, $SAPassword, $Login )
{
	$query = OSQL -S $SqlInstance -U sa -P $SAPassword -Q "select count(name) from master.sys.server_principals where name = '$Login'" -h-1
        return ($query[0].Trim() -eq "1")
}

function IsSrvRoleMember($SqlInstance, $SAPassword, $Login )
{
	$query = OSQL -S $SqlInstance -U sa -P $SAPassword -Q "select IS_srvRoleMember('sysadmin', '$Login')" -h-1
        return ($query[0].Trim() -eq "1")
}

function IsHAEnabled($SqlInstance, $SAPassword)
{
	$query = OSQL -S $SqlInstance -U sa -P $SAPassword -Q "select ServerProperty('IsHadrEnabled')" -h-1
	return ($query[0].Trim() -eq "1")
}

#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
    param
    (	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential, 
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$ServiceCredential
    )

    Write-Verbose -Message "Set SQL Service configuration ..."

    $SAPassword = $SqlAdministratorCredential.GetNetworkCredential().Password

    $ServiceAccount = $ServiceCredential.UserName

    
    $bServiceAccountInSqlLogin = IsSQLLogin -SqlInstance $InstanceName -SAPassword $SAPassword -Login $ServiceAccount

    $bServiceAccountInSrvRole = IsSrvRoleMember -SqlInstance $InstanceName -SAPassword $SAPassword -Login $ServiceCredential.UserName

    $bSystemAccountInSrvRole = IsSrvRoleMember -SqlInstance $InstanceName -SAPassword $SAPassword -Login "NT AUTHORITY\SYSTEM"

    $bHAEnabled = IsHAEnabled -SqlInstance $InstanceName -SAPassword $SAPassword

	return @{
        ServiceAccount = $ServiceAccount
        ServiceAccountInSqlLogin = $bServiceAccountInSqlLogin
        ServiceAccountInSrvRole = $bServiceAccountInSrvRole
        SystemAccountInSrvRole = $bSystemAccountInSrvRole
        HAEnabled = $bHAEnabled
    }
}

#
# The Set-TargetResource cmdlet.
#
function Set-TargetResource
{
    param
    (	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential, 
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$ServiceCredential
    )

    Write-Verbose -Message "Set SQL Service configuration ..."

    $SAPassword = $SqlAdministratorCredential.GetNetworkCredential().Password

    $ServiceAccount = $ServiceCredential.UserName
    $ServicePassword = $ServiceCredential.GetNetworkCredential().Password

    $bCheck = IsSQLLogin -SqlInstance $InstanceName -SAPassword $SAPassword -Login $ServiceAccount
    if ($false -eq $bCheck)
    {
        osql -S $InstanceName -U sa -P $SAPassword -Q "Create Login [$ServiceAccount] From Windows"
    }

    $bCheck = IsSrvRoleMember -SqlInstance $InstanceName -SAPassword $SAPassword -Login $ServiceAccount
    if ($false -eq $bCheck)
    {
    	osql -S $InstanceName -U sa -P $SAPassword -Q "Exec master.sys.sp_addsrvrolemember '$ServiceAccount', 'sysadmin'"
    }

    $bCheck = IsSrvRoleMember -SqlInstance $InstanceName -SAPassword $SAPassword -Login "NT AUTHORITY\SYSTEM"
    if ($false -eq $bCheck)
    {
	    osql -S $InstanceName -U sa -P $SAPassword -Q "Exec master.sys.sp_addsrvrolemember 'NT AUTHORITY\SYSTEM', 'sysadmin'"
    }

    $serviceName = Get-SqlServiceName -InstanceName $InstanceName
    $service = Get-WmiObject Win32_Service | ? { $_.Name -eq $serviceName }
    $service.Change($null,$null,$null,$null,$null,$null,$ServiceAccount,$ServicePassword,$null,$null,$null)
   
    RestartSqlServer

    $bCheck = IsHAEnabled -SqlInstance $InstanceName -SAPassword $SAPassword
    if ($false -eq $bCheck)
    {
        Enable-SqlAlwaysOn -ServerInstance $InstanceName -Force
        RestartSqlServer
    }

    # Tell the DSC Engine to restart the machine
    #$global:DSCMachineStatus = 1
}

#
# The Test-TargetResource cmdlet.
#
function Test-TargetResource
{
    param
    (	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential, 
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$ServiceCredential
    )

    Write-Verbose -Message "Test SQL Service configuration ..."

    $SAPassword = $SqlAdministratorCredential.GetNetworkCredential().Password
    $ServiceAccount = $ServiceCredential.UserName

    $ret = IsSQLLogin -SqlInstance $InstanceName -SAPassword $SAPassword -Login $ServiceAccount
    if ($false -eq $ret)
    {
        Write-Verbose -Message "$ServiceAccount is NOT in SqlServer login"
        return $false
    }

    $ret = IsSrvRoleMember -SqlInstance $InstanceName -SAPassword $SAPassword -Login $ServiceCredential.UserName
    if ($false -eq $ret)
    {
        Write-Verbose -Message "$ServiceCredential.UserName is NOT in admin role"
        return $false
    }

    $ret = IsSrvRoleMember -SqlInstance $InstanceName -SAPassword $SAPassword -Login "NT AUTHORITY\SYSTEM"
    if ($false -eq $ret)
    {
        Write-Verbose -Message "NT AUTHORITY\SYSTEM is NOT in admin role"
        return $false
    }

    $ret = IsHAEnabled -SqlInstance $InstanceName -SAPassword $SAPassword
    if ($false -eq $ret)
    {
        Write-Verbose -Message "$InstanceName does NOT enable SQL HA."
        return $false
    }

    return $ret
}


function Get-SqlServiceName ($InstanceName)
{
    $list = $InstanceName.Split("\")
    if ($list.Count -gt 1)
    {
        "MSSQL$" + $list[1]
    }
    else
    {
        "MSSQLSERVER"
    }
}

Export-ModuleMember -Function *-TargetResource
