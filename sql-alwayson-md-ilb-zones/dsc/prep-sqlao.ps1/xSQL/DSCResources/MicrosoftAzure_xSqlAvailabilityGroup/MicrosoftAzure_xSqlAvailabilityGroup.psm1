#
# xSqlAvailabilityGroup: DSC resource to configure a SQL AlwaysOn Availability Group.
#

function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $ClusterName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InstanceName,

        [ValidateRange(1000,9999)]
        [UInt32] $PortNumber = 5022,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    $bConfigured = Test-TargetResource -Name $Name -ClusterName $ClusterName -InstanceName $InstanceName -PortNumber $PortNumber -DomainCredential $DomainCredential -SqlAdministratorCredential $SqlAdministratorCredential

    $returnValue = @{
        Name = $Name
        ClusterName = $ClusterName
        InstanceName = $InstanceName
        PortNumber = $PortNumber
        DomainCredential = $DomainCredential.UserName
        SqlAdministratorCredential = $SqlAdministratorCredential.UserName
        Configured = $bConfigured
    }

    $returnValue
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $ClusterName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InstanceName,

        [ValidateRange(1000,9999)]
        [UInt32] $PortNumber = 5022,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    $computerInfo = Get-WmiObject Win32_ComputerSystem
    if (($computerInfo -eq $null) -or ($computerInfo.Domain -eq $null))
    {
        throw "Can't find node's domain name."
    }
    $domain = $ComputerInfo.Domain

    # Use the enumeration of cluster nodes as the replicas to add to the availability group.
    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainCredential

        Write-Verbose -Message "Enumerating nodes in cluster '$($ClusterName)' ..."
        $nodes = Get-ClusterNode -Cluster $ClusterName
        Write-Verbose -Message "Found $(($nodes).Count) nodes."
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

    # Find an existing availability group with the same name and look up its primary replica.
    Write-Verbose -Message "Checking if SQL AG '$($Name)' exists ..."
    $bAGExist = $false
    foreach ($node in $nodes.Name)
    {
        $instance = Get-SqlInstanceName -Node $node -InstanceName $InstanceName
        $s = Get-SqlServer -InstanceName $instance -Credential $SqlAdministratorCredential
        $group = Get-SqlAvailabilityGroup -Name $Name -Server $s
        if ($group)
        {
            Write-Verbose -Message "Found SQL AG '$($Name)' on instance '$($instance)'."
            $bAGExist = $true

            $primaryReplica = Get-SqlAvailabilityGroupPrimaryReplica -Name $Name -Server $s
            if ($primaryReplica -eq $env:COMPUTERNAME)
            {
                Write-Verbose -Message "Instance '$($instance)' is the primary replica in SQL AG '$($Name)'"
            }
        }
    }

    # Create the availability group and primary replica.
    if (!$bAGExist)
    {
        try
        {
            Write-Verbose -Message "Creating SQL AG '$($Name)' ..."
            $s = Get-SqlServer -InstanceName $InstanceName -Credential $SqlAdministratorCredential
            $instance = Get-SqlInstanceName -Node $env:COMPUTERNAME -InstanceName $InstanceName

            $newAG = New-Object -Type Microsoft.SqlServer.Management.Smo.AvailabilityGroup -ArgumentList $s,$Name
            $newAG.AutomatedBackupPreference = 'Secondary'

            $newPrimaryReplica = New-Object -Type Microsoft.SqlServer.Management.Smo.AvailabilityReplica -ArgumentList $newAG,$instance.ToUpperInvariant()
            $newPrimaryReplica.EndpointUrl = "TCP://$($s.NetName).$($domain):$PortNumber"
            $newPrimaryReplica.AvailabilityMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode]::SynchronousCommit
            $newPrimaryReplica.FailoverMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode]::Automatic
            $newAG.AvailabilityReplicas.Add($newPrimaryReplica)

            $s.AvailabilityGroups.Add($newAG)
            $newAG.Create()

            $primaryReplica = $s.NetName
        }
        catch
        {
            Write-Error "Error creating availability group '$($Name)'."
            throw $_
        }
    }

    # Create the secondary replicas and join them to the availability group.
    $nodeIndex = 2
    foreach ($node in $nodes.Name)
    {
        if ($node -eq $primaryReplica)
        {
            continue
        }

        Write-Verbose -Message "Adding replica '$($node)' to SQL AG '$($Name)' ..."
        $instance = Get-SqlInstanceName -Node $node -InstanceName $InstanceName

        # Most operations are performed on the primary replica.
        $s = Get-SqlServer -InstanceName $primaryReplica -Credential $SqlAdministratorCredential
        $group = Get-SqlAvailabilityGroup -Name $Name -Server $s

        # Ensure the replica is not currently in the availability group.
        $localReplica = Get-SqlAvailabilityGroupReplicas -Name $Name -Server $s | where { $_.Name -eq $node }
        if ($localReplica)
        {
            Write-Verbose -Message "Found replica '$($node)' in SQL AG '$($Name)', removing ..."
            $localReplica.Drop()
        }

        # Automatic failover can be specified for up to two availability replicas.
        if ($nodeIndex -le 2)
        {
            $failoverMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode]::Automatic
        }
        else
        {
            $failoverMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode]::Manual
        }

        # Synchronous commit can be specified for up to three availability replicas.
        if ($nodeIndex -le 3)
        {
            $availabilityMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode]::SynchronousCommit
        }
        else
        {
            $availabilityMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode]::AsynchronousCommit
        }

        # Add the replica to the availability group.
        $newReplica = New-Object -Type Microsoft.SqlServer.Management.Smo.AvailabilityReplica -ArgumentList $group,$instance.ToUpperInvariant()
        $newReplica.EndpointUrl = "TCP://$($node).$($domain):$PortNumber"
        $newReplica.AvailabilityMode = $availabilityMode
        $newReplica.FailoverMode = $failoverMode
        $group.AvailabilityReplicas.Add($newReplica)
        $newReplica.Create()
        $group.Alter()

        # Now join the replica to the availability group.
        $s = Get-SqlServer -InstanceName $instance -Credential $SqlAdministratorCredential
        $s.JoinAvailabilityGroup($group.Name)
        $s.Alter()
    }
}

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $ClusterName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InstanceName,

        [ValidateRange(1000,9999)]
        [UInt32] $PortNumber = 5022,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    Write-Verbose -Message "Checking if SQL AG '$($Name)' exists on instance '$($InstanceName) ..."

    $instance = Get-SqlInstanceName -Node $node -InstanceName $InstanceName
    $s = Get-SqlServer -InstanceName $instance -Credential $SqlAdministratorCredential
    $group = Get-SqlAvailabilityGroup -Name $Name -Server $s

    if ($group)
    {
        Write-Verbose -Message "SQL AG '$($Name)' found."
        $true
    }
    else
    {
        Write-Verbose -Message "SQL AG '$($Name)' NOT found."
        $false
    }

    # TODO: add additional tests for AG membership, port, etc.
}


function Get-SqlAvailabilityGroup([string]$Name, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    $s.AvailabilityGroups | where { $_.Name -eq $Name }
}

function Get-SqlAvailabilityGroupPrimaryReplica([string]$Name, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    $s.AvailabilityGroups | where { $_.Name -eq $Name } | select -ExpandProperty 'PrimaryReplicaServerName'
}

function Get-SqlAvailabilityGroupReplicas([string]$Name, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    $s.AvailabilityGroups | where { $_.Name -eq $Name } | select -ExpandProperty 'AvailabilityReplicas'
}

function Get-SqlServer([string]$InstanceName, [PSCredential]$Credential)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    
    $LoginCreataionRetry = 0

    While ($true) {
        
        try {
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

            #Can not find a proper documentation for setting ConnectTimeout to be forever so we use 300 seconds here which is the max time of the guest agent to determine timeout
            $sc.ConnectTimeout = 300

            Write-Verbose "name is $($SqlAdministratorCredential.UserName)"

            if ($SqlAdministratorCredential.GetNetworkCredential().Domain -and $SqlAdministratorCredential.GetNetworkCredential().Domain -ne $env:COMPUTERNAME)
            {
                $sc.ConnectAsUserName = "$($SqlAdministratorCredential.GetNetworkCredential().UserName)@$($SqlAdministratorCredential.GetNetworkCredential().Domain)"
            }
            else
            {
                $sc.ConnectAsUserName = $SqlAdministratorCredential.GetNetworkCredential().UserName
            }
            $sc.ConnectAsUserPassword = $SqlAdministratorCredential.GetNetworkCredential().Password

            [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

            $s = New-Object Microsoft.SqlServer.Management.Smo.Server $sc

            if ($s.Information.Version) {
                    
                $s.Refresh()
            
                Write-Verbose "SQL Management Object Created Successfully, Version : '$($s.Information.Version)' "   
            
            }
            else
            {
                throw "SQL Management Object Creation Failed"
            }
            
            return $s

        }
        catch [System.Exception] 
        {
            $LoginCreationRetry = $LoginCreationRetry + 1
            
            if ($_.Exception.InnerException) {                   
             $ErrorMSG = "Error occured: '$($_.Exception.Message)',InnerException: '$($_.Exception.InnerException.Message)',  failed after '$($LoginCreationRetry)' times"
            } 
            else 
            {               
             $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($LoginCreationRetry)' times"
            }
            
            if ($LoginCreationRetry -eq 30) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($LoginCreationRetry)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 60

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($LoginCreationRetry)' times"
        }
    }
}

function Get-SqlInstanceName([string]$Node, [string]$InstanceName)
{
    $pureInstanceName = Get-PureSqlInstanceName -InstanceName $InstanceName
    if ("MSSQLSERVER" -eq $pureInstanceName)
    {
        $Node
    }
    else
    {
        $Node + "\" + $pureInstanceName
    }
}

function Get-PureSqlInstanceName([string]$InstanceName)
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
