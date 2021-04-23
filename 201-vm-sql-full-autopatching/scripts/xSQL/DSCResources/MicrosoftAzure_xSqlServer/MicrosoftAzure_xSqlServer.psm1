#
# xSQLServer: DSC resource to configure a SQL Server. This resource supports
#   configuration of the SQL Server service account, database and log folders,
#   and MAXDOP. This resource is intended to be used to configure a SQL Server
#   instance for use with SharePoint.
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

        [ValidateNotNullOrEmpty()]
        [PSCredential] $ServiceCredential,

        [ValidateNotNullOrEmpty()]
        [String] $LoginMode,

        [ValidateSet("Enabled", "Disabled")]
        [String] $Hadr,

        [ValidateRange(0, 32767)]
        [uint32] $MaxDegreeOfParallelism,

        [ValidateNotNullOrEmpty()]
        [String] $FilePath,

        [ValidateNotNullOrEmpty()]
        [String] $LogPath,

        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainAdministratorCredential
    )

    $s = Get-SqlServer -InstanceName $InstanceName -Credential $SqlAdministratorCredential

    $serviceAccount = Get-ServiceAccount -InstanceName $InstanceName -Server $s

    $retval = @{
        InstanceName = $InstanceName
        SqlAdministratorCredential = $SqlAdministratorCredential.UserName
        ServiceCredential = New-Object System.Management.Automation.PSCredential ($serviceAccount, (New-Object System.Security.SecureString))
        LoginMode = $s.Settings.LoginMode
        Hadr = if ($s.IsHadrEnabled) { "Enabled" } else { "Disabled" }
        MaxDegreeOfParallelism = $s.Configuration.MaxDegreeOfParallelism.ConfigValue
        FilePath = $s.DefaultFile
        LogPath = $s.DefaultLog
        DomainAdministratorCredential = $DomainAdministratorCredential.UserName
    }

    $retval
}

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

        [ValidateNotNullOrEmpty()]
        [PSCredential] $ServiceCredential,

        [ValidateNotNullOrEmpty()]
        [String] $LoginMode,

        [ValidateSet("Enabled", "Disabled")]
        [String] $Hadr,

        [ValidateRange(0, 32767)]
        [int] $MaxDegreeOfParallelism,

        [ValidateNotNullOrEmpty()]
        [String] $FilePath,

        [ValidateNotNullOrEmpty()]
        [String] $LogPath,

        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainAdministratorCredential
    )

    Write-Verbose -Message "Configuring SQL Server instance '$($InstanceName)' ..."

    Start-SqlServer -InstanceName $InstanceName

    $s = Get-SqlServer -InstanceName $InstanceName -Credential $SqlAdministratorCredential

    if ($ServiceCredential)
    {
        $bCheck = IsSQLLogin -Login $ServiceCredential -Server $s
        if (!$bCheck)
        {
            Write-Verbose -Message "Creating login for '$($ServiceCredential.UserName)' ..."
            $login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $s, $ServiceCredential.UserName
            $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::WindowsUser
            $login.PasswordExpirationEnabled = $false
            $login.Create($ServiceCredential.GetNetworkCredential().SecurePassword)
        }

        $bCheck = IsSysAdmin -Login $ServiceCredential -Server $s
        if (!$bCheck)
        {
            Write-Verbose -Message "Adding login '$($ServiceCredential.UserName)' to 'sysadmin' server role ..."
            $role = $s.Roles | where { $_.Name -eq "sysadmin" }
            $role.AddMember($ServiceCredential.UserName)
        }

        Update-SpnPermissions -ServiceCredential $ServiceCredential -DomainAdministratorCredential $DomainAdministratorCredential

        Grant-LogonAsAServiceRight -ServiceCredential $ServiceCredential -DomainAdministratorCredential $DomainAdministratorCredential

        Set-ServiceAccount -Credential $ServiceCredential -InstanceName $InstanceName -Server $s
    }

    $systemCredential = New-Object System.Management.Automation.PSCredential ("NT AUTHORITY\SYSTEM", (New-Object System.Security.SecureString))
    $bCheck = IsSQLLogin -Login $systemCredential -Server $s
    if (!$bCheck)
    {
        Write-Verbose -Message "Creating login for '$($systemCredential.UserName)' ..."
        $login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $s, $systemCredential.UserName
        $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::WindowsUser
        $login.PasswordExpirationEnabled = $false
        $login.Create($systemCredential.GetNetworkCredential().SecurePassword)
    }

    $bCheck = IsSysAdmin -Login $systemCredential -Server $s
    if (!$bCheck)
    {
        Write-Verbose -Message "Adding login '$($systemCredential.UserName)' to 'sysadmin' server role ..."
        $role = $s.Roles | where { $_.Name -eq "sysadmin" }
        $role.AddMember($systemCredential.UserName)
    }

    $sps = New-Object Microsoft.SqlServer.Management.Smo.ServerPermissionSet
    $sps.Add([Microsoft.SqlServer.Management.Smo.ServerPermission]::AlterAnyAvailabilityGroup) | Out-Null
    $sps.Add([Microsoft.SqlServer.Management.Smo.ServerPermission]::ConnectSql) | Out-Null
    $sps.Add([Microsoft.SqlServer.Management.Smo.ServerPermission]::ViewServerState) | Out-Null
    $spis = $s.EnumServerPermissions($systemCredential.UserName, $sps)
    if ($spis.Count -ne 3)
    {
        # These permissions are required per http://msdn.microsoft.com/library/jj870963.aspx.
        Write-Verbose -Message "Granting permissions to '$($systemCredential.UserName)' ..."
        $perms = New-Object Microsoft.SqlServer.Management.Smo.ServerPermissionSet
        $perms.AlterAnyAvailabilityGroup = $true
        $perms.ConnectSql = $true
        $perms.ViewServerState = $true
        $s.Grant($perms, $systemCredential.UserName)
    }

    $bCheck = $s.LoginMode -eq $LoginMode
    if ($LoginMode -and !$bCheck)
    {
        Write-Verbose -Message "Setting login mode to '$($LoginMode)' ..."
        $s.Settings.LoginMode = $LoginMode
        $s.Settings.Alter()
        $bRestartRequired = $true
    }

    $bCheck = $s.Configuration.MaxDegreeOfParallelism.ConfigValue -eq $MaxDegreeOfParallelism
    if ($MaxDegreeOfParallelism -and !$bCheck)
    {
        Write-Verbose -Message "Setting 'max degree of parallelism' to '$($MaxDegreeOfParallelism)' ..."
        $s.Configuration.MaxDegreeOfParallelism.ConfigValue = $MaxDegreeOfParallelism
        $s.Configuration.Alter()
        $bRestartRequired = $true
    }

    if ($Hadr)
    {
        # Normalize the instance name.
        $list = $InstanceName.Split("\")
        if ($list.Count -gt 1 -and $list[1] -eq "MSSQLSERVER")
        {
            $serverInstance = $list[0]
            $computerName= $list[0]
            $instanceName="MSSQLSERVER"
        }
        else
        {      
            $serverInstance = $InstanceName
            if ($list.Count -eq 1 )
            {
                $computerName= $list[0]
                $instanceName="MSSQLSERVER"
            }
            else
            {
                $computerName= $list[0]
                $instanceName="MSSQLSERVER"
            }
        }
        
        if ($instanceName -eq "MSSQLSERVER")
        {
            $path="SQLSERVER:\SQL\${computerName}\Default"
        }
        else
        {
            $path="SQLSERVER:\SQL\${computerName}\${instanceName}"
        }

        if ($computerName -eq $env:COMPUTERNAME)
        {
            Set-HADR -Path $path -Hadr $Hadr
        }
        else
        {
            Invoke-Command -ScriptBlock ${Function:Set-HADR} -ComputerName $computerName -Credential $DomainAdministratorCredential -ArgumentList $path,$Hadr
        }
       
    }
    
    $bCheck = $s.DefaultFile.TrimEnd("\") -eq $FilePath.TrimEnd("\")
    if ($FilePath -and !$bCheck)
    {
        Write-Verbose -Message "Changing the SQL default file path to '$($FilePath)' ..."
        #New-Item -ItemType Directory -Path $FilePath -Force
        [System.IO.Directory]::CreateDirectory($FilePath) | Out-Null
        $s.Settings.DefaultFile = $FilePath
        $s.Settings.Alter()
        $bRestartRequired = $true
    }

    $bCheck = $s.DefaultLog.TrimEnd("\") -eq $LogPath.TrimEnd("\")
    if ($LogPath -and !$bCheck)
    {
        Write-Verbose -Message "Changing the SQL default log path to '$($LogPath)' ..."
        #New-Item -ItemType Directory -Path $LogPath -Force
        [System.IO.Directory]::CreateDirectory($LogPath) | Out-Null
        $s.Settings.DefaultLog = $LogPath
        $s.Settings.Alter()
        $bRestartRequired = $true
    }
    if ($LogPath -and $FilePath)
    {
         Write-Verbose -Message "Changing the SQL system database default log path to '$($LogPath)' ..."
         Write-Verbose -Message "Changing the SQL system database default file path to '$($FilePath)' ..."
         Alter-SystemDatabaseLocation -FilePath $FilePath -LogPath $LogPath -ServiceCredential $ServiceCredential
         Stop-SqlServer -InstanceName $InstanceName -Server $s
         Move-SystemDatabaseFile -FilePath $FilePath -LogPath $LogPath -ServiceCredential $ServiceCredential
         Start-SqlServer -InstanceName $InstanceName -Server $s
         $bRestartRequired= $false
     }

    if ($bRestartRequired)
    {
        Restart-SqlServer -InstanceName $InstanceName -Server $s
    }
}
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

        [ValidateNotNullOrEmpty()]
        [PSCredential] $ServiceCredential,

        [ValidateNotNullOrEmpty()]
        [String] $LoginMode,

        [ValidateSet("Enabled", "Disabled")]
        [String] $Hadr,

        [ValidateRange(0, 32767)]
        [int] $MaxDegreeOfParallelism,

        [ValidateNotNullOrEmpty()]
        [String] $FilePath,

        [ValidateNotNullOrEmpty()]
        [String] $LogPath,

        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainAdministratorCredential
    )

    Write-Verbose -Message "Testing the SQL Server instance '$($InstanceName)' ..."

    if (-not (Start-SqlServer -InstanceName $InstanceName)) {
        return $false
    }

    $s = Get-SqlServer -InstanceName $InstanceName -Credential $SqlAdministratorCredential

    if ($ServiceCredential)
    {
        $bCheck = IsSQLLogin -Login $ServiceCredential -Server $s
        if (!$bCheck)
        {
            Write-Verbose -Message "Login for '$($ServiceCredential.UserName)' does NOT exist."
            return $false
        }

        $bCheck = IsSysAdmin -Login $ServiceCredential -Server $s
        if (!$bCheck)
        {
            Write-Verbose -Message "Login '$($ServiceCredential.UserName)' is NOT in 'sysadmin' server role."
            return $false
        }

        $serviceAccount = Get-ServiceAccount -InstanceName $InstanceName -Server $s
        if ($serviceAccount -ne $ServiceCredential.UserName)
        {
            Write-Verbose -Message "Service account is NOT '$($ServiceCredential.UserName)'."
            return $false
        }
    }

    $systemCredential = New-Object System.Management.Automation.PSCredential ("NT AUTHORITY\SYSTEM", (New-Object System.Security.SecureString))
    $bCheck = IsSQLLogin -Login $systemCredential -Server $s
    if (!$bCheck)
    {
        Write-Verbose -Message "Login for '$($systemCredential.UserName)' does NOT exist."
        return $false
    }

    $bCheck = IsSysAdmin -Login $systemCredential -Server $s
    if (!$bCheck)
    {
        Write-Verbose -Message "Login '$($systemCredential.UserName)' is NOT in 'sysadmin' server role."
        return $false
    }

    $sps = New-Object Microsoft.SqlServer.Management.Smo.ServerPermissionSet
    $sps.Add([Microsoft.SqlServer.Management.Smo.ServerPermission]::AlterAnyAvailabilityGroup) | Out-Null
    $sps.Add([Microsoft.SqlServer.Management.Smo.ServerPermission]::ConnectSql) | Out-Null
    $sps.Add([Microsoft.SqlServer.Management.Smo.ServerPermission]::ViewServerState) | Out-Null
    $spis = $s.EnumServerPermissions($systemCredential.UserName, $sps)
    if ($spis.Count -lt 3)
    {
        Write-Verbose -Message "Login '$($systemCredential.UserName)' does NOT have the correct permissions."
        return $false
    }

    $bCheck = $s.LoginMode -eq $LoginMode
    if ($LoginMode -and !$bCheck)
    {
        Write-Verbose -Message "Server login mode is NOT '$($LoginMode)'."
        return $false
    }

    $bCheck = $s.Configuration.MaxDegreeOfParallelism.ConfigValue -eq $MaxDegreeOfParallelism
    if ($MaxDegreeOfParallelism -and !$bCheck)
    {
        Write-Verbose -Message "Server setting 'max degree of parallelism' is NOT '$($MaxDegreeOfParallelism)'."
        return $false
    }

    if ($Hadr)
    {
        if ($Hadr -eq "Enabled" -and !$s.IsHadrEnabled)
        {
            Write-Verbose -Message "SQL Always On should NOT be disabled."
            return $false
        }
        if ($Hadr -eq "Disabled" -and $s.IsHadrEnabled)
        {
            Write-Verbose -Message "SQL Always On should NOT be enabled."
            return $false
        }
    }

    $bCheck = $s.DefaultFile.TrimEnd("\") -eq $FilePath.TrimEnd("\")
    if ($FilePath -and !$bCheck)
    {
        Write-Verbose -Message "The server default file path is NOT '$($FilePath)' ..."
        return $false
    }

    $bCheck = $s.DefaultLog.TrimEnd("\") -eq $LogPath.TrimEnd("\")
    if ($LogPath -and !$bCheck)
    {
        Write-Verbose -Message "The server default log path is NOT '$($LogPath)' ..."
        return $false
    }

    $true
}

function Set-HADR()
{
    param(
        [string]$Path,
        [string]$Hadr
    )


    import-module sqlps -DisableNameChecking|Out-Null

    $VerbosePreference='Continue'

    $loopnumber=1
    $loopuntil=5

    do 
    {
        try {
            if ($Hadr -eq "Enabled")
            {
                Write-Verbose -Message "Enabling SQL AlwaysOn at Path $path Attempt $loopnumber"
                Enable-SqlAlwaysOn -Path $Path -Force
                break
            }
            else
            {
                Write-Verbose -Message "Disabling SQL AlwaysOn at Path $path Attempt $loopnumber"
                Disable-SqlAlwaysOn -Path  $Path -Force
                break
            }
        }
        catch {
            if ($loopnumber -lt $loopuntil)
            {
                $loopnumber++
            }
            else
            {
                throw
            }
        }
    } while ($loopnumber -lt $loopuntil)
}
function Update-SpnPermissions([PSCredential]$ServiceCredential, [PSCredential]$DomainAdministratorCredential)
{
    if ($DomainAdministratorCredential)
    {
        Write-Verbose -Message "Granting '$($ServiceCredential.UserName)' Read/Write servicePrincipalName permissions ..."
        try
        {
            ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential

            $domain = $ServiceCredential.GetNetworkCredential().Domain
            $userName = $ServiceCredential.GetNetworkCredential().UserName
            $identity = New-Object System.Security.Principal.NTAccount($domain, $userName)
            $searcher = New-Object System.DirectoryServices.DirectorySearcher([adsi]'')
            $searcher.filter = "(&(objectCategory=person)(sAMAccountName=$userName))"
            $targetObject = $searcher.FindOne().GetDirectoryEntry()

            $rootDSE = [adsi]"LDAP://RootDSE"
            $schemaDN = $rootDSE.psbase.properties["schemaNamingContext"][0]
            $spnEntry = [adsi]"LDAP://CN=Service-Principal-Name,$schemaDN"
            $guidArg=@("")
            $guidArg[0]=$spnEntry.psbase.Properties["schemaIDGUID"][0]
            $spnSecGuid = New-Object GUID $guidArg
            $adRight=[DirectoryServices.ActiveDirectoryRights]"readproperty,writeproperty"
            $spnAce = New-Object DirectoryServices.ActiveDirectoryAccessRule $identity,$adRight,"Allow",$spnSecGuid,"None"
            $targetObject.psbase.ObjectSecurity.AddAccessRule($spnAce)
            $targetObject.psbase.CommitChanges()
        }
        catch
        {
            Write-Warning -Message "Error granting '$($ServiceCredential.UserName)' Read/Write servicePrincipalName permissions."
            Write-Warning -Message $_
        }
        finally
        {
            if ($context)
            {
                $context.Undo()
                $context.Dispose()
                CloseUserToken($newToken)
            }
        }
    }
    else
    {
        Write-Warning -Message "DomainAdministratorCredential was not specified. You must configured the SPNs for '$($ServiceCredential.UserName)' manually."
    }
}

function Grant-LogonAsAServiceRight([PSCredential]$ServiceCredential, [PSCredential]$DomainAdministratorCredential)
{
    if ($DomainAdministratorCredential)
    {
        Write-Verbose -Message "Granting '$($ServiceCredential.UserName)' 'Log on as a service' rights ..."
        try
        {
            ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential
            AddAccountRights -account $ServiceCredential -rights "SeServiceLogonRight"
        }
        catch
        {
            Write-Warning -Message "Error granting '$($ServiceCredential.UserName)' 'Log on as a service' rights."
            Write-Warning -Message $_
        }
        finally
        {
            if ($context)
            {
                $context.Undo()
                $context.Dispose()
                CloseUserToken($newToken)
            }
        }
    }
    else
    {
        Write-Warning -Message "DomainAdministratorCredential was not specified. You must grant '$($ServiceAccount)' 'Log on as a service' rights manually."
    }

}


function Alter-SystemDatabaseLocation([string]$FilePath, [string]$LogPath,[PSCredential]$ServiceCredential )
{
	$permissionString = $ServiceCredential.UserName+":(OI)(CI)(F)"
    icacls $FilePath /grant $permissionString
    icacls $LogPath /grant $permissionString

    Invoke-Sqlcmd "Use master"
    Invoke-sqlCmd "ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = '$FilePath\tempdb.mdf');"
    Invoke-sqlCmd "ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = '$LogPath\templog.ldf');"

    Invoke-sqlCmd "ALTER DATABASE model MODIFY FILE (NAME = modeldev, FILENAME = '$FilePath\model.mdf');"
    Invoke-sqlCmd "ALTER DATABASE model MODIFY FILE (NAME = modellog, FILENAME = '$LogPath\modellog.ldf');"

    Invoke-sqlCmd "ALTER DATABASE msdb MODIFY FILE (NAME = MSDBData, FILENAME = '$FilePath\msdbdata.mdf');"
    Invoke-sqlCmd "ALTER DATABASE msdb MODIFY FILE (NAME = MSDBLog, FILENAME = '$LogPath\msdblog.ldf');"

	[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement')| Out-Null
    $smowmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer 
    $sqlsvc = $smowmi.Services | Where-Object {$_.Name -like 'MSSQL*'} 
    $OldStartupParameters = $sqlsvc.StartupParameters
    $params = '-d'+$FilePath+'\master.mdf;-e'+$LogPath+'\ERRORLOG;-l'+$LogPath+'\mastlog.ldf'
    $sqlsvc[1].StartupParameters = $params
    $sqlsvc[1].Alter()
}


function Move-SystemDatabaseFile([string]$FilePath, [string]$LogPath, [PSCredential]$ServiceCredential )
{
	if (Test-Path "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\") 
	{
     #Move Sql Server 2014 system databases location
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\msdbdata.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\msdblog.ldf" $LogPath –force

     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\model.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\modellog.ldf" $LogPath -force

     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\tempdb.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\templog.ldf" $LogPath -force

     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\master.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\mastlog.ldf" $LogPath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Log\ERRORLOG" $LogPath -force
	}
   
	if (Test-Path "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\") 
	{
     #Move Sql Server 2012 system databases location
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\msdbdata.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\msdblog.ldf" $LogPath –force

     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\model.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\modellog.ldf" $LogPath -force

     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\tempdb.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\templog.ldf" $LogPath -force

     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\master.mdf" $FilePath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\mastlog.ldf" $LogPath -force
     Move-Item "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\ERRORLOG" $LogPath -force
    }
}


function Get-ServiceAccount([string]$InstanceName, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
    $mc = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $Server.Name
    # Normalize the instance name.
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

    $svc.ServiceAccount
}

function Set-ServiceAccount([PSCredential]$Credential, [string]$InstanceName, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    Write-Verbose -Message "Setting the service account to '$($Credential.UserName)' ..."
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
    $mc = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $Server.Name
    # Normalize the instance name.
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

    $tcpPort = $mc.ServerInstances[$InstanceName].ServerProtocols["Tcp"].IPAddresses["IPAll"].IPAddressProperties["TcpPort"].Value

    # Remove any leftover SPNs.
    $spns = setspn -L $mc.Name
    foreach ($spn in $spns)
    {
        $spn = $spn.Trim()
        if ($spn -like "MSSQLSvc/*:$tcpPort")
        {
            # Remove the SPN that matches the TCP/IP port of this instance.
            setspn -D $spn $mc.Name | Out-Null
            continue
        }

        if ($spn -like "MSSQLSvc/*:$InstanceName")
        {
            # Remove the SPN that matches this named instance.
            setspn -D $spn $mc.Name | Out-Null
        }
        elseif ($spn -like "MSSQLSvc/*:*")
        {
            # Skip an SPN that matches a different named instance.
            continue
        }
        elseif ($spn -like "MSSQLSvc/*")
        {
            # Remove the SPN that matches the default instance.
            setspn -D $spn $mc.Name | Out-Null
        }
    }

    $svc.SetServiceAccount($Credential.UserName, $Credential.GetNetworkCredential().Password)
}

function Start-SqlServer([string]$InstanceName, [Microsoft.SqlServer.Management.Smo.Server]$Server)
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

    Write-Verbose -Message "Starting SQL server instance '$($InstanceName)' ..."
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.WmiEnum") | Out-Null
    if ($svc.ServiceState -eq [Microsoft.SqlServer.Management.Smo.Wmi.ServiceState]::Stopped)
    {
        $svc.Start()
		while ($svc.ServiceState -ne [Microsoft.SqlServer.Management.Smo.Wmi.ServiceState]::Running)
		{
			$svc.Refresh()
		}
    }
}

function Stop-SqlServer([string]$InstanceName, [Microsoft.SqlServer.Management.Smo.Server]$Server)
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

    Write-Verbose -Message "Stopping SQL server instance '$($InstanceName)' ..."
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.WmiEnum") | Out-Null
    $svc.Stop()
    $svc.Refresh()
    while ($svc.ServiceState -ne [Microsoft.SqlServer.Management.Smo.Wmi.ServiceState]::Stopped)
    {
        $svc.Refresh()
    }
}



function Restart-SqlServer([string]$InstanceName, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
     Stop-SqlServer -InstanceName $InstanceName -Server $s

     Start-SqlServer -InstanceName $InstanceName -Server $s
}

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
        $sc.ServerInstance = $InstanceName
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

function IsSQLLogin([PSCredential]$Login, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    $domain = $Login.GetNetworkCredential().Domain
    $userName = $Login.GetNetworkCredential().UserName
    if ($server.Logins | where { $_.Name -eq "$domain\$username" })
    {
        return $true
    }

    $false
}

function IsSysAdmin([PSCredential]$Login, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    $domain = $Login.GetNetworkCredential().Domain
    $userName = $Login.GetNetworkCredential().UserName
    $role = $server.Roles | where { $_.Name -eq "sysadmin" }
    if ($role.EnumMemberNames().Contains("$domain\$username"))
    {
        return $true
    }

    $false
}

function Get-LsaLib
{
    if ($script:LsaLib)
    {
        return $script:LsaLib
    }

    $lsa_type = @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Principal;
using LSA_HANDLE = System.IntPtr;

public sealed class LsaSecurityWrapper
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct LSA_OBJECT_ATTRIBUTES
    {
        internal ulong Length;
        internal IntPtr RootDirectory;
        internal IntPtr ObjectName;
        internal ulong Attributes;
        internal IntPtr SecurityDescriptor;
        internal IntPtr SecurityQualityOfService;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    internal struct LSA_UNICODE_STRING
    {
        internal ushort Length;
        internal ushort MaximumLength;
        [MarshalAs(UnmanagedType.LPWStr)]
        internal string Buffer;
    }

    [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true), SuppressUnmanagedCodeSecurityAttribute]
    internal static extern uint LsaOpenPolicy(
        LSA_UNICODE_STRING[] SystemName,
        ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
        uint DesiredAccess,
        out IntPtr PolicyHandle
        );

    [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true), SuppressUnmanagedCodeSecurityAttribute]
    internal static extern uint LsaAddAccountRights(
        LSA_HANDLE PolicyHandle,
        IntPtr AccountSid,
        LSA_UNICODE_STRING[] UserRights,
        ulong CountOfRights
        );

    [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true), SuppressUnmanagedCodeSecurityAttribute]
    internal static extern uint LsaRemoveAccountRights(
        LSA_HANDLE PolicyHandle,
        IntPtr AccountSid,
        bool AllRights,
        ref LSA_UNICODE_STRING UserRights,
        ulong CountOfRights
        );

    [DllImport("advapi32.dll", SetLastError = true)]
    internal static extern int LsaClose(LSA_HANDLE PolicyHandle);

    private enum Access : uint
    {
        POLICY_READ = 0x20006,
        POLICY_ALL_ACCESS = 0x00F0FFF,
        POLICY_EXECUTE = 0X20801,
        POLICY_WRITE = 0X207F8
    }

    public static void AddAccountRights(SecurityIdentifier sid, string rights)
    {
        LSA_HANDLE lsaHandle = IntPtr.Zero;
        LSA_UNICODE_STRING[] system = null;
        LSA_OBJECT_ATTRIBUTES lsaAttr;
        lsaAttr.RootDirectory = IntPtr.Zero;
        lsaAttr.ObjectName = IntPtr.Zero;
        lsaAttr.Attributes = 0;
        lsaAttr.SecurityDescriptor = IntPtr.Zero;
        lsaAttr.SecurityQualityOfService = IntPtr.Zero;
        lsaAttr.Length = (ulong)Marshal.SizeOf(typeof(LSA_OBJECT_ATTRIBUTES));

        uint ret = LsaOpenPolicy(system, ref lsaAttr, (int)Access.POLICY_ALL_ACCESS, out lsaHandle);
        if (ret == 0)
        {
            Byte[] buffer = new Byte[sid.BinaryLength];
            sid.GetBinaryForm(buffer, 0);

            IntPtr pSid = Marshal.AllocHGlobal(sid.BinaryLength);
            Marshal.Copy(buffer, 0, pSid, sid.BinaryLength);

            LSA_UNICODE_STRING[] privileges = new LSA_UNICODE_STRING[1];

            LSA_UNICODE_STRING lsaRights = new LSA_UNICODE_STRING();
            lsaRights.Buffer = rights;
            lsaRights.Length = (ushort)(rights.Length * sizeof(char));
            lsaRights.MaximumLength = (ushort)(lsaRights.Length + sizeof(char));

            privileges[0] = lsaRights;

            ret = LsaAddAccountRights(lsaHandle, pSid, privileges, 1);

            LsaClose(lsaHandle);

            Marshal.FreeHGlobal(pSid);

            if (ret != 0)
            {
                throw new Win32Exception("LsaAddAccountRights failed with error code: " + ret);
            }
        }
        else
        {
            throw new Win32Exception("LsaOpenPolicy failed with error code: " + ret);
        }
    }
}
'@
    $script:LsaLib = Add-Type -PassThru -TypeDefinition $lsa_type
    return $script:LsaLib
}

function AddAccountRights([PSCredential]$account, [String[]]$rights)
{
    $LsaLib = Get-LsaLib
    $domain = $account.GetNetworkCredential().Domain
    $userName = $account.GetNetworkCredential().UserName
    $identity = (New-Object System.Security.Principal.NTAccount($domain, $userName)).Translate([System.Security.Principal.SecurityIdentifier])

    foreach ($right in $rights)
    {
        [LsaSecurityWrapper]::AddAccountRights($identity, $right)
    }
}

function Get-ImpersonateLib
{
    if ($script:ImpersonateLib)
    {
        return $script:ImpersonateLib
    }

    $sig = @'
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

[DllImport("kernel32.dll")]
public static extern Boolean CloseHandle(IntPtr hObject);
'@
   $script:ImpersonateLib = Add-Type -PassThru -Namespace 'Lib.Impersonation' -Name ImpersonationLib -MemberDefinition $sig

   return $script:ImpersonateLib
}

function ImpersonateAs([PSCredential] $cred)
{
    [IntPtr] $userToken = [Security.Principal.WindowsIdentity]::GetCurrent().Token
    $userToken
    $ImpersonateLib = Get-ImpersonateLib

    $bLogin = $ImpersonateLib::LogonUser($cred.GetNetworkCredential().UserName, $cred.GetNetworkCredential().Domain, $cred.GetNetworkCredential().Password, 
    9, 0, [ref]$userToken)

    if ($bLogin)
    {
        $Identity = New-Object Security.Principal.WindowsIdentity $userToken
        $context = $Identity.Impersonate()
    }
    else
    {
        throw "Can't log on as user '$($cred.GetNetworkCredential().UserName)'."
    }
    $context, $userToken
}

function CloseUserToken([IntPtr] $token)
{
    $ImpersonateLib = Get-ImpersonateLib

    $bLogin = $ImpersonateLib::CloseHandle($token)
    if (!$bLogin)
    {
        throw "Can't close token."
    }
}


Export-ModuleMember -Function *-TargetResource
