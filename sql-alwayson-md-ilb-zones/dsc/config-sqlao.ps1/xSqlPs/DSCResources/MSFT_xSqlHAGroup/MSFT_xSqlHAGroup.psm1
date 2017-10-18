#
# xSqlHAGroup: DSC resource to configure a Sql High Availability (HA) Group. If the HA Group does not exist, it will 
# create one with given name on given sql instance, it also adds the database(s) to the group. If the HA group
# already exists, it will join sql instance to the group, replicate the database(s) in the group to local instance.
#

#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
	param
	(	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [parameter(Mandatory)]
        [ValidateNotNull()]
	    [string[]] $Database,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ClusterName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $DatabaseBackupPath,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $InstanceName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $EndpointName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential	
  	)

    if ($Database.Count -lt 1)
    {
        throw "Parameter Database does not have any database"
    }

    $bConfigured = Test-TargetResource -Name $Name -Database $Database -ClusterName $ClusterName -DatabaseBackupPath $DatabaseBackupPath -InstanceName $InstanceName -EndpointName $EndpointName -DomainCredential $DomainCredential -SqlAdministratorCredential $SqlAdministratorCredential

    $returnValue = @{
 
        Database = $Database
        Name = $Name
        ClusterName = $ClusterName
        DatabaseBackupPath = $DatabaseBackupPath
        InstanceName = $InstanceName
        EndpointName = $EndpointName

        DomainCredential = $DomainCredential.UserName
        SqlAdministratorCredential = $SqlAdministratorCredential.UserName

        Configured = $bConfigured
	}

	$returnValue
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
        [string] $Name,

        [parameter(Mandatory)]
        [ValidateNotNull()]
	    [string[]] $Database,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ClusterName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $DatabaseBackupPath,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $InstanceName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $EndpointName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential	
  	)

    if ($Database.Count -lt 1)
    {
        throw "Parameter Database does not have any database"
    }

    Write-Verbose -Message "Checking if SQL HAG $Name is present ..."
    Write-Verbose -Message "Cluster: $ClusterName, Database: $Database"

    $bHAGExist = $false
    $primaryReplica = $InstanceName

    $sa = $SqlAdministratorCredential.UserName
    $saPassword = $SqlAdministratorCredential.GetNetworkCredential().Password

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainCredential    
        $nodes = Get-ClusterNode -Cluster $ClusterName
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

    foreach ($node in $nodes.Name)
    {
        $instance = Get-SQLInstanceName -node $node -InstanceName $InstanceName

        $bCheck = Check-SQLHAGroup -InstanceName $instance -Name $Name -sa $sa -saPassword $saPassword
        if ($bCheck)
        {
            Write-Verbose -Message "Found SQL HAG $Name on instance $instance"
            $bHAGExist = $true

            # check if it is the primary replica
            $bPrimaryCheck = Check-SQLHAGroupPrimaryReplica -InstanceName $instance -Name $Name -sa $sa -saPassword $saPassword
            if ($bPrimaryCheck)
            {
                $primaryReplica = $instance
            }
        }
    }

    if ($bHAGExist)
    {
        Write-Verbose -Message "Add instance $InstanceName to SQL HAG $Name"
        
        $bCheckPreviousInstance = Check-SQLHAGroupReplicaExist -InstanceName $InstanceName -Name $Name -PrimaryInstanceName $primaryReplica -sa $sa -saPassword $saPassword
        if ($bCheckPreviousInstance)
        {
            Write-Verbose -Message "SQLHAGroup $Name already has the instance $InstanceName, clean up first"
            $query = "alter availability group $Name `
                                        remove replica on '$InstanceName'"

            Write-Verbose -Message "Query: $query"
            osql -S $primaryReplica -U $sa -P $saPassword -Q $query
        }
   

        # Add this instance to HAG group on instance $primaryInstance
        $query = "alter availability group $Name `
                                        add replica on '$InstanceName' with `
                                        ( `
                                            EndPoint_URL = 'TCP://$EndpointName', `
                                            Availability_Mode = Synchronous_Commit, `
                                            Failover_Mode = Automatic, `
                                            Secondary_Role(Allow_connections = ALL) `
                                         ) "

	    Write-Verbose -Message "Query: $query"
        osql -S $primaryReplica -U $sa -P $saPassword -Q $query

        # Add this node to HAG 
	    osql -S $InstanceName -U $sa -P $saPassword -Q "ALTER AVAILABILITY GROUP $Name JOIN"

        # restore database
        foreach($db in $Database)
        {
            $query = "restore database $db from disk = '$DatabaseBackupPath\$db.bak' with norecovery"
            Write-Verbose -Message "Instance $InstanceName Query: $query"
            osql -S $InstanceName -U $sa -P $saPassword -Q $query
        

            $query = "restore log $db from disk = '$DatabaseBackupPath\$db.log' with norecovery "
            Write-Verbose -Message "Query: $query"
	        osql -S $InstanceName -U $sa -P $saPassword -Q $query

            # Add database to HAG
	        osql -S $InstanceName -U $sa -P $saPassword -Q "ALTER DATABASE $db SET HADR AVAILABILITY GROUP = $Name"
        }
    }

    else # create
    {
        Write-Verbose -Message "Create SQL HAG $Name and primary instance $InstanceName"

        foreach($db in $Database)
        {
	        Write-Verbose -Message "Create database $db ..."
            osql -S $InstanceName -U $sa -P $saPassword -Q "if not exists (select * from master.sys.databases where name = '$db') begin Create database $db end;"	

	        Write-Verbose -Message "Backup to $DatabaseBackupPath .."
            osql -S $InstanceName -U $sa -P $saPassword -Q "backup database $db to disk = '$DatabaseBackupPath\$db.bak' with format"
        }

        $dblist = "$Database" -replace " ", ", "

        Write-Verbose -Message "AG: $Name "
        $query =  "Create Availability Group $Name `
                                    For Database $Database `
                                    Replica ON `
                                    '$InstanceName' with `
                                    ( `
                                        ENDPOINT_URL = 'TCP://$EndpointName', `
                                        Availability_Mode = Synchronous_Commit, `
                                        Failover_Mode = Automatic `
                                     )"

	    Write-Verbose -Message "Create HAG : $query.."
        osql -S $InstanceName -U $sa -P $saPassword -Q $query

        foreach($db in $Database)
        {
	        Write-Verbose -Message "Backup Log to $DatabaseBackupPath .."
            osql -S $InstanceName -U $sa -P $saPassword -Q "backup log $db to disk = '$DatabaseBackupPath\$db.log' with NOFormat"
        }
   }


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
        [string] $Name,

        [parameter(Mandatory)]
        [ValidateNotNull()]
	    [string[]] $Database,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ClusterName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $DatabaseBackupPath,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $InstanceName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
	    [string] $EndpointName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential	
  	)

    if ($Database.Count -lt 1)
    {
        throw "Parameter Database does not have any database"
    }

    Write-Verbose -Message "Checking if SQL HA Group $Name on instance $InstanceName present ..."

    $sa = $SqlAdministratorCredential.UserName
    $saPassword = $SqlAdministratorCredential.GetNetworkCredential().Password

    $bFound = Check-SQLHAGroup -InstanceName $InstanceName -Name $Name -sa $sa -saPassword $saPassword
    if ($bFound)
    {
        Write-Verbose -Message "SQL HA Group $Name is present"
        $true
    }
    else
    {
        Write-Verbose -Message "SQL HA Group $Name not found"
        $false
    }
}


function Check-SQLHAGroup($InstanceName, $Name, $sa, $saPassword)
{
    Write-Verbose -Message "Check HAG $Name including instance $InstanceName ..."
    $query = OSQL -S $InstanceName -U $sa -P $saPassword -Q "select count(name) from master.sys.availability_groups where name = '$Name'" -h-1
    
    Write-Verbose -Message "SQL: $query"
    
    [bool] [int] ([String] $query[0]).Trim()
}


function Check-SQLHAGroupPrimaryReplica($InstanceName, $Name, $sa, $saPassword)
{
    $query = OSQL -S $InstanceName -U $sa -P $saPassword -Q "select count(replica_id) from sys.dm_hadr_availability_replica_states s `
                                        inner join sys.availability_groups g on g.group_id = s.group_id `
                                        where g.name = '$Name' and s.role_desc = 'PRIMARY' and s.is_local = 1" -h-1
    [bool] [int] ([string] $query[0]).Trim()
}

function Check-SQLHAGroupReplicaExist($InstanceName, $Name, $PrimaryInstanceName, $sa, $saPassword)
{
    $query = OSQL -S $PrimaryInstanceName -U $sa -P $saPassword -Q "select count(replica_id) from sys.availability_replicas r `
                                        inner join sys.availability_groups g on g.group_id = r.group_id `
                                        where g.name = '$Name' and r.replica_server_name = '$InstanceName' " -h-1
    [bool] [int] ([string] $query[0]).Trim()

}

function Get-PureInstanceName ($InstanceName)
{
    $list = $InstanceName.Split("\")
    if ($list.Count -gt 1)
    {
        $list[1]
    }
    else
    {
        "MSSQLSERVER"
    }
}

function Get-SQLInstanceName ($node, $InstanceName)
{
    $pureInstanceName = Get-PureInstanceName -InstanceName $InstanceName

    if ("MSSQLSERVER" -eq $pureInstanceName)
    {
        $node
    }
    else
    {
        $node + "\" + $pureInstanceName
    }
}


function Get-ImpersonatetLib
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
    $ImpersonateLib = Get-ImpersonatetLib

    $bLogin = $ImpersonateLib::LogonUser($cred.GetNetworkCredential().UserName, $cred.GetNetworkCredential().Domain, $cred.GetNetworkCredential().Password, 
    9, 0, [ref]$userToken)
    
    if ($bLogin)
    {
        $Identity = New-Object Security.Principal.WindowsIdentity $userToken
        $context = $Identity.Impersonate()
    }
    else
    {
        throw "Can't Logon as User $cred.GetNetworkCredential().UserName."
    }
    $context, $userToken
}

function CloseUserToken([IntPtr] $token)
{
    $ImpersonateLib = Get-ImpersonatetLib

    $bLogin = $ImpersonateLib::CloseHandle($token)
    if (!$bLogin)
    {
        throw "Can't close token"
    }
}


Export-ModuleMember -Function *-TargetResource