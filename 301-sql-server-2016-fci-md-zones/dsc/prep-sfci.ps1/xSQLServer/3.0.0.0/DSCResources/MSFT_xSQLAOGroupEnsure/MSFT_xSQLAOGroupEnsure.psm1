$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose -Message "CurrentPath: $currentPath"

Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupName,
        
        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [ValidateNotNull()] 
        [System.String]
        $SQLInstanceName= 'MSSQLSERVER',

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -SetupCredential $SetupCredential
    
    $vConfigured = Test-TargetResource -Ensure $Ensure -AvailabilityGroupName $AvailabilityGroupName -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -SetupCredential $SetupCredential

    $returnValue = @{
        Ensure = $vConfigured
        AvailabilityGroupName = $sql.AvailabilityGroups[$AvailabilityGroupName]
        AvailabilityGroupNameListener = $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.name
        AvailabilityGroupNameIP = $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.availabilitygrouplisteneripaddresses.IPAddress
        AvailabilityGroupSubMask =  $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.availabilitygrouplisteneripaddresses.SubnetMask
        AvailabilityGroupPort =  $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityGroupListeners.portnumber
        AvailabilityGroupNameDatabase = $sql.AvailabilityGroups[$AvailabilityGroupName].AvailabilityDatabases.name
        BackupDirectory = ''
        SQLServer = $SQLServer
        SQLInstanceName = $SQLInstanceName
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupName,

        [System.String]
        $AvailabilityGroupNameListener = $AvailabilityGroupName,

        [System.String[]]
        $AvailabilityGroupNameIP,

        [System.String[]]
        $AvailabilityGroupSubMask,

        [System.UInt32]
        $AvailabilityGroupPort = '1433',

        [ValidateSet('None', 'ReadOnly', 'ReadIntent')]
        [System.String]
        $ReadableSecondary = 'ReadOnly',

        [ValidateSet('Primary', 'Secondary')]
        [System.String]
        $AutoBackupPreference = 'Primary',
        
        [System.UInt32]
        $BackupPriority = '50',
        
        [System.UInt32]
        $EndPointPort = '5022',

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = 'MSSQLSERVER',
        
        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
    $null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SmoExtended')
   
    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -SetupCredential $SetupCredential

    if (($AvailabilityGroupNameIP -and !$AvailabilityGroupSubMask) -or (!$AvailabilityGroupNameIP -and $AvailabilityGroupSubMask))
    {
        throw 'AvailabilityGroupNameIP and AvailabilityGroupSubMask must both be passed for Static IP assignment.'
    }

    switch ($Ensure)
    {
        'Present'
        {
            Grant-ServerPerms -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -AuthorizedUser 'NT AUTHORITY\SYSTEM' -SetupCredential $SetupCredential
            New-ListenerADObject -AvailabilityGroupNameListener $AvailabilityGroupNameListener -SetupCredential $SetupCredential -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
 
            $FailoverCondition = 3
            $HealthCheckTimeout = 30000
            $ConnectionModeInPrimary = 'AllowAllConnections'    

            $ConnectionModeInSecondaryRole = switch ($ReadableSecondary)
            {
                'None'
                {
                    'AllowNoConnections'
                }
                
                'ReadOnly'
                {
                    'AllowAllConnections'
                }
                
                'ReadIntent'
                {
                    'AllowReadIntentConnectionsOnly'
                }
                
                Default 
                {
                    'AllowAllConnections'
                }
            } 

           # Get Servers participating in the cluster
           # First two nodes will account for Syncronous Automatic Failover, Any additional will be Asyncronous
           try
           {
                $nodes = Get-ClusterNode -cluster $sql.ClusterName -Verbose:$false | Select-Object -ExpandProperty name
                $syncNodes = $nodes | Select-Object -First 2
                $asyncNodes = $nodes | Select-Object -Skip 2
                $availabilityGroup = New-Object -typename Microsoft.SqlServer.Management.Smo.AvailabilityGroup -ArgumentList $SQL, $AvailabilityGroupName
                $availabilityGroup.AutomatedBackupPreference = $AutoBackupPreference
                $availabilityGroup.FailureConditionLevel = $FailoverCondition
                $availabilityGroup.HealthCheckTimeout = $HealthCheckTimeout
           }
           catch
           {
                throw "Failed to connect to Cluster Nodes from $($sql.ClusterName)"
           }

           # Loop through Sync nodes Create Replica Object Assign properties and add it to AvailabilityGroup
           foreach ($node in $syncNodes)
           { 
                Try
                {
                    $Replica = New-Object -typename Microsoft.SqlServer.Management.Smo.AvailabilityReplica -ArgumentList $availabilityGroup, $node
                    $Replica.EndpointUrl = "TCP://$($node):$EndPointPort"
                    $Replica.FailoverMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode]::Automatic
                    $Replica.AvailabilityMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode]::SynchronousCommit
                    # Backup Priority Gives the ability to set a priority of one secondany over another valid values are from 1 - 100
                    $Replica.BackupPriority = $BackupPriority
                    $Replica.ConnectionModeInPrimaryRole = $ConnectionModeInPrimary
                    $replica.ConnectionModeInSecondaryRole = $ConnectionModeInSecondaryRole 
                    $availabilityGroup.AvailabilityReplicas.Add($Replica)
                }
                catch
                {
                    throw "Failed to add $Replica to the Availability Group $AvailabilityGroupName"
                }         
            }

            # Loop through ASync nodes Create Replica Object Assign properties and add it to AvailabilityGroup
            foreach ($node in $AsyncNodes)
            {
                try
                {
                    $asyncReplica = New-Object -typename Microsoft.SqlServer.Management.Smo.AvailabilityReplica -ArgumentList $availabilityGroup, $node
                    $asyncReplica.EndpointUrl = "TCP://$($node):$EndPointPort"
                    $asyncReplica.FailoverMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode]::Manual
                    $asyncReplica.AvailabilityMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode]::ASynchronousCommit
                    $asyncReplica.BackupPriority = $BackupPriority
                    $asyncReplica.ConnectionModeInPrimaryRole =  $ConnectionModeInPrimary
                    $asyncReplica.ConnectionModeInSecondaryRole = $ConnectionModeInSecondaryRole 
                    $AvailabilityGroup.AvailabilityReplicas.Add($asyncReplica)
                }
                catch
                {
                    Write-Error "Failed to add $asyncReplica to the Availability Group $AvailabilityGroupName"
                }
            }
        
            try
            {
                $AgListener = New-Object -typename Microsoft.SqlServer.Management.Smo.AvailabilityGroupListener -ArgumentList $AvailabilityGroup, $AvailabilityGroupNameListener
                $AgListener.PortNumber =$AvailabilityGroupPort
            }
            catch
            {
                Write-Error -Message ('{0}: Failed to Create AG Listener Object' -f ((Get-Date -format yyyy-MM-dd_HH-mm-ss)))
            }
         
         
            if ($AvailabilityGroupNameIP)
            {
                foreach ($IP in $AvailabilityGroupNameIP)
                {
                    $AgListenerIp = New-Object -typename Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress -ArgumentList $AgListener
                    $AgListenerIp.IsDHCP = $false
                    $AgListenerIp.IPAddress = $IP
                    $AgListenerIp.SubnetMask = $AvailabilityGroupSubMask
                    $AgListener.AvailabilityGroupListenerIPAddresses.Add($AgListenerIp)
                    New-VerboseMessage -Message "Added Static IP $IP to $AvailabilityGroupNameListener..."
            
                }
            }
            else
            {
                # Utilize Dynamic IP since no Ip was passed
                $AgListenerIp = New-Object -typename Microsoft.SqlServer.Management.Smo.AvailabilityGroupListenerIPAddress -ArgumentList $AgListener
                $AgListenerIp.IsDHCP = $true
                $AgListener.AvailabilityGroupListenerIPAddresses.Add($AgListenerIp)
                New-VerboseMessage -Message "Added DynamicIP to $AvailabilityGroupNameListener..."
            }
         
            try
            {
                $AvailabilityGroup.AvailabilityGroupListeners.Add($AgListener);
            }
            catch
            {
                throw "Failed to Add $AvailabilityGroupNameListener to $AvailabilityGroupName..."
            }    

            # Add Availabilty Group to the SQL connection
            try
            {
                $SQL.AvailabilityGroups.Add($availabilityGroup)
                New-VerboseMessage -Message "Added $availabilityGroupName Availability Group to Connection"  
            }
            catch
            {
                throw "Unable to Add $AvailabilityGroup to $SQLServer\$SQLInstanceName"
            }
           
            # Create Availability Group
            try
            {
                $availabilityGroup.Create()

                New-VerboseMessage -Message "Created Availability Group $availabilityGroupName"
            }
            catch
            {
                throw "Unable to Create $AvailabilityGroup on $SQLServer\$SQLInstanceName"
            }
        }

        'Absent'
        { 
            try
            {
                 $sql.AvailabilityGroups[$AvailabilityGroupName].Drop()

                 New-VerboseMessage -Message "Dropped $AvailabilityGroupName" 
            }
            catch
            {
                 throw "Unable to Drop $AvailabilityGroup on $SQLServer\$SQLInstanceName"
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
        [parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroupName,

        [System.String]
        $AvailabilityGroupNameListener,

        [System.String[]]
        $AvailabilityGroupNameIP,

        [System.String[]]
        $AvailabilityGroupSubMask,

        [System.UInt32]
        $AvailabilityGroupPort,

        [ValidateSet('None', 'ReadOnly', 'ReadIntent')]
        [System.String]
        $ReadableSecondary ='ReadOnly',

        [ValidateSet('Primary', 'Secondary')]
        [System.String]
        $AutoBackupPreference = 'Primary',
        
        [System.UInt32]
        $BackupPriority = '50',
        
        [System.UInt32]
        $EndPointPort = '5022',

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = 'MSSQLSERVER',
        
        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName -SetupCredential $SetupCredential

    $result = $false

    switch ($Ensure)
    {
        'Present'
        {
            $availabilityGroupPresent = $sql.AvailabilityGroups.Contains($AvailabilityGroupName)
            if ($availabilityGroupPresent)
            {
                $result = $true
            }
        }

        'Absent'
        {
            if (!$sql.AvailabilityGroups[$AvailabilityGroupName])
            {
                $result = $true
            }
        }
    }

    return $result
}

Export-ModuleMember -Function *-TargetResource
