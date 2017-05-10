#
# xbtsSqlAvailabilityGroup: DSC resource to configure a SQL AlwaysOn Availability Group on a VM in Azure.
#
# Adapted from:
# ~\sqlvm-alwayson-cluster\scripts\CreateFailoverCluster.ps1\xSQL\DSCResources\MicrosoftAzure_xSqlAvailabilityGroup\MicrosoftAzure_xSqlAvailabilityGroup.psm1
# Significant differences are:
#  * node names as parameter instead of querying the cluster; avoids troublesome domain query
#  * set the 'Enable DTC' option when creating AG; required by BizTalk
#  * set ConnectionMode of secondary replicas to 'ReadOnly'
#  * fixed the secondary replica counting/indexing (was hard-coded $nodeIndex variable) to apply
#     correct, intended AvailabilityMode and FailoverMode when node count is greater than 3
#  * extracted New-AvailabilityReplica logic into its own function
#  * fixed basic functionality of Test-TargetResource
#  * fixed and clarified support for named instances
#

function Get-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $InstanceName,

		[parameter(Mandatory)]
		[string] $Name,

		[parameter(Mandatory)][ValidateCount(1,9)]
		[string[]] $Nodes,

		[ValidateRange(1000,9999)]
		[UInt32] $EndpointPort = 5022,

		[Parameter(Mandatory)]
		[PSCredential] $SqlAdministrator
	)

	$isConfigured = Test-TargetResource @PSBoundParameters

	@{
		Name = $Name
		InstanceName = $InstanceName
		Nodes = $Nodes
		EndpointPort = $EndpointPort
		SqlAdministrator = $SqlAdministrator.UserName
		Configured = $isConfigured
	}
}

function Set-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $InstanceName,

		[parameter(Mandatory)]
		[string] $Name,

		[parameter(Mandatory)][ValidateCount(1,9)]
		[string[]] $Nodes,

		[ValidateRange(1000,9999)]
		[UInt32] $EndpointPort = 5022,

		[Parameter(Mandatory)]
		[PSCredential] $SqlAdministrator
	)

	$computerInfo = Get-WmiObject Win32_ComputerSystem
	if (($computerInfo -eq $null) -or ($computerInfo.Domain -eq $null))
	{
		throw "Can't find this node's domain name."
	}
	$domainName = $computerInfo.Domain

	# find existing availability group and look up its primary replica
	Write-Verbose -Message "Checking if SQL AG '$Name' exists ..."
	$group = $null
	foreach ($nodeName in $Nodes)
	{
		$sqlNode = Connect-SqlInstance $nodeName $InstanceName -Credential $SqlAdministrator
		$group = Find-SqlAvailabilityGroup -Name $Name -Server $sqlNode
		if ($group)
		{
			Write-Verbose -Message "Found SQL AG '$Name' on instance '$nodeName\$InstanceName'."

			$primaryNodeName = $group.PrimaryReplicaServerName
			Write-Verbose -Message "SQL AG '$Name' primary replica node is '$primaryNodeName'."
			break
		}
	}

	# create availability group and primary replica
	if (-not $group)
	{
		try
		{
			Write-Verbose -Message "Creating SQL AG '$Name' ..."
			$sqlLocal = Connect-SqlInstance $env:COMPUTERNAME $InstanceName -Credential $SqlAdministrator

			$newAG = New-Object -Type Microsoft.SqlServer.Management.Smo.AvailabilityGroup -Args $sqlLocal, $Name
			$newAG.AutomatedBackupPreference = 'Secondary'
			$newAG.DtcSupportEnabled = $true

			$newPrimaryReplica = New-AvailabilityReplica -replicaNumber 1 `
					-availabilityGroup $newAG -nodeName $sqlLocal.NetName -instanceName $InstanceName `
					-domainName $domainName -endpointPort $EndpointPort
			$newAG.AvailabilityReplicas.Add($newPrimaryReplica)

			$sqlLocal.AvailabilityGroups.Add($newAG)
			$newAG.Create()

			$primaryNodeName = $sqlLocal.NetName
			Write-Verbose -Message "Created SQL AG '$Name'."
		}
		catch
		{
			Write-Error "Error creating availability group '$Name'."
			throw
		}
	}

	# Create the secondary replicas and join them to the availability group.
	$nodeNumber = 1
	foreach ($nodeName in $Nodes.Where{$_ -ne $primaryNodeName})
	{
		# primary replica node is counted as node #1, and is assumed to have been created
		# as "-replicaNumber 1", per the 'Creating SQL AG...' code block above
		$nodeNumber++

		Write-Verbose -Message "Adding replica node '$nodeName' to SQL AG '$Name' ..."

		# Most operations are performed on the primary replica.
		# CONSIDER: can't this $group acquisition be pulled outside-above this loop?
		$sqlPrimary = Connect-SqlInstance $primaryNodeName $InstanceName -Credential $SqlAdministrator
		$group = Find-SqlAvailabilityGroup -Name $Name -Server $sqlPrimary

		# if node is already in AG, drop & recreate it to ensure desired, correct settings 
		$localReplica = $group.AvailabilityReplicas | Where-Object 'Name' -eq $nodeName
		if ($localReplica)
		{
			Write-Verbose -Message "Found existing node '$nodeName' in SQL AG '$Name', removing it prior to adding ..."
			$localReplica.Drop()
		}

		# create & add the replica to the availability group
		$newReplica = New-AvailabilityReplica -replicaNumber $nodeNumber `
				-availabilityGroup $group -nodeName $nodeName -instanceName $InstanceName `
				-domainName $domainName -endpointPort $EndpointPort
		$group.AvailabilityReplicas.Add($newReplica)
		$newReplica.Create()
		$group.Alter()

		# join the node to the availability group
		$sqlNode = Connect-SqlInstance $nodeName $InstanceName -Credential $SqlAdministrator
		$sqlNode.JoinAvailabilityGroup($group.Name)
		$sqlNode.Alter()

		Write-Verbose -Message "Added replica node '$nodeName' to SQL AG '$Name'."
	}
}

function Test-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $InstanceName,

		[parameter(Mandatory)]
		[string] $Name,

		[parameter(Mandatory)][ValidateCount(1,9)]
		[string[]] $Nodes,

		[ValidateRange(1000,9999)]
		[UInt32] $EndpointPort = 5022,

		[Parameter(Mandatory)]
		[PSCredential] $SqlAdministrator
	)

	# for now, just query the local server for the AG (as opposed to looping through $Nodes)
	Write-Verbose -Message "Checking if SQL AG '$Name' exists on local instance '$InstanceName' ..."
	$sqlLocal = Connect-SqlInstance $env:COMPUTERNAME $InstanceName -Credential $SqlAdministrator

	$group = Find-SqlAvailabilityGroup -Name $Name -Server $sqlLocal
	if ($group)
	{
		Write-Verbose -Message "SQL AG '$Name' found."
		$true
	}
	else
	{
		Write-Verbose -Message "SQL AG '$Name' NOT found."
		$false
	}

	# TODO: add additional tests for AG membership, port, etc.
}

#.SYNOPSIS
# Gets a connection to a SQL Server instance. 
function Connect-SqlInstance
{
	param	(
		[parameter(Mandatory)] [string] $ServerName = $env:COMPUTERNAME,
		[parameter(Mandatory)] [string] $InstanceName = 'MSSQLSERVER',
		[parameter(Mandatory)] [PSCredential] $Credential
	)

	[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null

	$conn = New-Object Microsoft.SqlServer.Management.Common.ServerConnection

	$conn.ServerInstance = Get-ServerInstance $ServerName $InstanceName

	$conn.ConnectAsUser = $true
	$netCred = $Credential.GetNetworkCredential()
	if ($netCred.Domain -and $netCred.Domain -ne $env:COMPUTERNAME)
	{
		$conn.ConnectAsUserName = "$($netCred.UserName)@$($netCred.Domain)"
	}
	else
	{
		$conn.ConnectAsUserName = $netCred.UserName
	}
	$conn.ConnectAsUserPassword = $netCred.Password

	New-Object Microsoft.SqlServer.Management.Smo.Server $conn
}

#.SYNOPSIS
# Creates a new availability replica object in memory.
function New-AvailabilityReplica($availabilityGroup, [string]$nodeName, [string]$instanceName,
		[string]$domainName, [uint32]$endpointPort, [int]$replicaNumber)
{
	# SynchronousCommit and Automatic failover can be specified for up to three replicas
	if ($replicaNumber -le 3)
	{
		$availabilityMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode]::SynchronousCommit
		$failoverMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode]::Automatic
	}
	else
	{
		$availabilityMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaAvailabilityMode]::AsynchronousCommit
		$failoverMode = [Microsoft.SqlServer.Management.Smo.AvailabilityReplicaFailoverMode]::Manual
	}

	New-Object -Type Microsoft.SqlServer.Management.Smo.AvailabilityReplica `
			-ArgumentList @(
				$availabilityGroup,
				(Get-ServerInstance $nodeName $instanceName)
			) -Property @{
				EndpointUrl = "tcp://$nodeName.${domainName}:$endpointPort".ToLowerInvariant()
				AvailabilityMode = $availabilityMode
				FailoverMode = $failoverMode
				ConnectionModeInPrimaryRole = `
					[Microsoft.SqlServer.Management.Smo.AvailabilityReplicaConnectionModeInPrimaryRole]::AllowAllConnections
				ConnectionModeInSecondaryRole = `
					[Microsoft.SqlServer.Management.Smo.AvailabilityReplicaConnectionModeInSecondaryRole]::AllowAllConnections
			}
}

#.SYNOPSIS
# Finds a named AvailabilityGroup within a SQL Server instance.
function Find-SqlAvailabilityGroup([string]$Name, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
	$Server.AvailabilityGroups | Where-Object Name -eq $Name
}

#.SYNOPSIS
# Constructs a SQL server-instance name.
function Get-ServerInstance([string] $serverName, [string] $instanceName)
{
	if ($instanceName -eq 'MSSQLSERVER')
	{
		$si = $serverName
	}
	else
	{
		$si = "$serverName\$instanceName"
	}

	$si.ToUpperInvariant()
}

Export-ModuleMember -Function *-TargetResource
