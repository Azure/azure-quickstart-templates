#.SYNOPSIS
# Creates and configures a SQL instance as an Always-On Availability Group.
#.DESCRIPTION
# This configuration is designed to be called multiple times in order to create multiple SQL
# instances and availability groups. The set of parameters with naming prefix 'Base' are the names
# and values that are unique to each created instance/group. The 'SequenceNumber' value is
# appended or added to each respective Base value to determine the actual value to use when
# creating the instance/group.
#.EXAMPLE
# $params = @{
#     DomainName = 'contoso.local'
#     SqlNodeNames = 'sqlserver-0', 'sqlserver-1'
#     AdminCredential = (Get-Credential -Message 'Admin account name and password')
#     SequenceNumber = 1
#     BaseListenerAddress = '10.1.1.150' }
# CreateConfigureAoag @params
#
configuration CreateConfigureAoag
{
	param
	(
		# Domain name; either short name or fully-qualified OK.
		[parameter(Mandatory)] [string] $DomainName,

		# Names of the SQL Server machines to be configured with AoAG.  
		[parameter(Mandatory)][ValidateCount(1,2)] [string[]] $SqlNodeNames,

		# Name of the Windows failover cluster to create.
		[Parameter(Mandatory)]
		[string] $ClusterName,

		# Fileshare witness path to assign to the created cluster for quorum purposes.
		[Parameter(Mandatory)]
		[string] $ClusterWitnessSharePath,

		# Administrator account name & password.
		# The UserName (with Password) should exist both in the domain and on the local machine.
		# Do not include a domain-name portion in the UserName value.
		[parameter(Mandatory)][ValidateScript({-not $_.UserName.Contains('\')})]
				[PSCredential] $AdminCredential,

		# Sequence number of the SQL instance and availability group to create.
		# This value is used as a suffix or increment to the base names and values.
		[parameter(Mandatory)][ValidateRange(1,9)] [int] $SequenceNumber,

		[string] $BaseInstanceName      = 'AG',
		[int]    $BaseInstancePort      = 50000,
		[string] $BaseEndpointName      = 'Hadr_endpoint_' + $BaseInstanceName,
		[int]    $BaseEndpointPort      = 5021,
		[string] $BaseAoagName          = 'Ao' + $BaseInstanceName,
		[string] $BaseListenerName      = $BaseInstanceName.ToLower() + '-ln',
		[ValidatePattern('^\d+(\.\d+){3}$')]
		[string] $BaseListenerAddress   = '10.0.0.100',
		[int]    $BaseListenerPort      = 1432,
		[int]    $BaseListenerProbePort = 60000
	)

	# we know the VMs we're using have SQL setup available here
	# CONSIDER: parameterize this
	[string] $sqlSourcePath = 'C:\SQLServer_13.0_Full'

	[string] $sqlInstanceName       = $BaseInstanceName      + $SequenceNumber
	[int]    $sqlInstancePort       = $BaseInstancePort      + $SequenceNumber
	[string] $hadrEndpointName      = $BaseEndpointName      + $SequenceNumber
	[string] $hadrEndpointPort      = $BaseEndpointPort      + $SequenceNumber
	[string] $aoagName              = $BaseAoagName          + $SequenceNumber
	[string] $aoagListenerName      = $BaseListenerName      + $SequenceNumber
	[string] $aoagListenerAddress   = IncrementIpAddress $BaseListenerAddress $SequenceNumber
	[int]    $aoagListenerPort      = $BaseListenerPort      + $SequenceNumber
	[int]    $aoagListenerProbePort = $BaseListenerProbePort - $SequenceNumber
	
	[string] $domainShortName = GetShortDomainName $DomainName

	[PSCredential] $domainAdminCredential = [PSCredential]::new(
			$domainShortName + '\' + $AdminCredential.UserName, $AdminCredential.Password)

	[string] $primaryNodeName = $SqlNodeNames[0]
	[string] $replicaNodeName = $SqlNodeNames[1]

	if ($env:COMPUTERNAME -notin $SqlNodeNames)
	{
		Write-Warning "This machine compiling this configuration is not within the set of names specified by SqlNodeNames ($SqlNodeNames); if the configuration will be applied to this machine, it may not be effective."
	}

	Import-DscResource -Module xSqlServer
	Import-DscResource -Module xFailOverCluster
	Import-DscResource -Module xNetworking
	Import-DscResource -Module xbtsBizTalkAoag

	foreach ($nodeName in $SqlNodeNames)
	{
		[PSCredential] $localAdminCredential = [PSCredential]::new(
				$nodeName + '\' + $AdminCredential.UserName, $AdminCredential.Password)

		Node $nodeName
		{
			if ($nodeName -eq $primaryNodeName)
			{
				# create cluster & add both nodes to it
				xbtsCluster $ClusterName
				{
					Name = $ClusterName
					Nodes = $SqlNodeNames
					PsDscRunAsCredential = $domainAdminCredential
				}

				xClusterQuorum $ClusterName
				{
					# note: current version (v3.0.0.0) of this resource assumes cluster of interest is the local cluster
					#Name = $ClusterName
					IsSingleInstance = 'Yes'
					Type = 'NodeAndFileShareMajority'
					Resource = $ClusterWitnessSharePath
					PsDscRunAsCredential = $domainAdminCredential
					DependsOn = "[xbtsCluster]$ClusterName"
				}
			}

			xSqlServerPowerPlan $nodeName
			{
				Ensure = "Present" # i.e., high-performance
			}

			xSqlServerSetup "$nodeName-$sqlInstanceName"
			{
				SourcePath = $sqlSourcePath
				SourceFolder = ''
				SetupCredential = $localAdminCredential
				Features = 'SQLENGINE'
				InstanceName = $sqlInstanceName
				InstallSQLDataDir = "F:\data.$sqlInstanceName"
				SQLUserDBDir      = "F:\data.$sqlInstanceName"
				SQLUserDBLogDir   = "F:\log.$sqlInstanceName"
				SQLSvcAccount = $domainAdminCredential
				AgtSvcAccount = $domainAdminCredential

				# although this param is an array, a bug in the implementation (v3.0.0.0) prevents
				#  specifying more than one additional account
				# note the implementation always adds the specified SetupCredential username
				SQLSysAdminAccounts = $domainAdminCredential.UserName
			}

			xSqlServerNetwork "$nodeName-$sqlInstanceName"
			{
				InstanceName = $sqlInstanceName
				ProtocolName = 'tcp'
				TCPPort = $sqlInstancePort
				IsEnabled = $true
				RestartService = $true
				DependsOn = "[xSqlServerSetup]$nodeName-$sqlInstanceName"
			}

			# open firewall for the instance, not a particular port
			xSqlServerFirewall "$nodeName-$sqlInstanceName"
			{
				SourcePath = $sqlSourcePath
				SourceFolder = ''
				Features = 'SQLENGINE'
				InstanceName = $sqlInstanceName
				Ensure = 'Present'
				DependsOn = "[xSqlServerSetup]$nodeName-$sqlInstanceName"
			}

			xFirewall "$nodeName-$aoagListenerName"
			{
				Name = "SQL-AGListener-$aoagListenerName-TCPIn"
				DisplayName = "SQL Availability Group Listener $aoagListenerName (TCP-In)"
				Description = "Inbound rule for SQL Availability Group Listener '$aoagListenerName' probe port."
				Group = 'SQL Server'
				Ensure = 'Present'
				Enabled = 'True'
				Direction = 'Inbound'
				Action = 'Allow'
				Protocol = 'TCP'
				LocalPort = @($aoagListenerProbePort.ToString())
			}

			xSqlServerMemory "$nodeName-$sqlInstanceName"
			{
				Ensure = "Present"
				DynamicAlloc = $true
				SqlInstanceName = $sqlInstanceName
				DependsOn = "[xSqlServerSetup]$nodeName-$sqlInstanceName"
			}

			# max degrees of parallelism
			xSqlServerMaxDop "$nodeName-$sqlInstanceName"
			{
				Ensure = "Present"
				DynamicAlloc = $true
				SqlInstanceName = $sqlInstanceName
				DependsOn = "[xSqlServerSetup]$nodeName-$sqlInstanceName"
			}

			xSqlServerEndpoint "$nodeName-$sqlInstanceName"
			{
				Ensure = 'Present'
				EndPointName = $hadrEndpointName
				Port = $hadrEndpointPort
				AuthorizedUser = $domainAdminCredential.UserName
				SQLInstanceName = $sqlInstanceName
				DependsOn = "[xSqlServerSetup]$nodeName-$sqlInstanceName"
			}

			xSqlServerAlwaysOnService "$nodeName-$sqlInstanceName"
			{
				Ensure = 'Present'
				SQLInstanceName = $sqlInstanceName
				DependsOn = "[xSqlServerSetup]$nodeName-$sqlInstanceName"
			}

			if ($nodeName -eq $primaryNodeName)
			{
				xbtsSqlWaitForInstance "$replicaNodeName-$sqlInstanceName"
				{
					ServerName = $replicaNodeName
					InstanceName = $sqlInstanceName
					SqlUser = $domainAdminCredential
					DependsOn = @(
							"[xbtsCluster]$ClusterName",
							"[xSqlServerEndpoint]$nodeName-$sqlInstanceName",
							"[xSqlServerAlwaysOnService]$nodeName-$sqlInstanceName")
				}

				xbtsSqlAvailabilityGroup $aoagName
				{
					InstanceName = $sqlInstanceName
					Name = $aoagName
					Nodes = $SqlNodeNames
					EndpointPort = $hadrEndpointPort
					SqlAdministrator = $domainAdminCredential
					DependsOn = "[xbtsSqlWaitForInstance]$replicaNodeName-$sqlInstanceName"
				}

				xbtsSqlAvailabilityGroupListener $aoagListenerName
				{
					InstanceName = $sqlInstanceName
					AvailabilityGroupName = $aoagName
					Name = $aoagListenerName
					IpAddress = $aoagListenerAddress
					Port = $aoagListenerPort
					ProbePort = $aoagListenerProbePort
					SqlAdministrator = $domainAdminCredential
					PsDscRunAsCredential = $domainAdminCredential
					DependsOn = "[xbtsSqlAvailabilityGroup]$aoagName"
				}
			}
			elseif ($nodeName -eq $replicaNodeName)
			{
				xWaitForAvailabilityGroup $aoagName
				{
					Name = $aoagName
					DependsOn = @(
							"[xSqlServerEndpoint]$nodeName-$sqlInstanceName",
							"[xSqlServerAlwaysOnService]$nodeName-$sqlInstanceName")
				}
			}

		} # Node
	} # foreach
} # configuration


function IncrementIpAddress ([string] $baseAddress, [int] $increment = 1)
{
	[int] $lastOctetIndex = $baseAddress.LastIndexOf('.') + 1
	[int] $lastOctet = [int] $baseAddress.Substring($lastOctetIndex)

	$lastOctet += $increment
	if ($lastOctet -gt 255)
	{
		throw "Cannot increment IP address '$baseAddress' by $increment because the last octet would be greater than 255."
	}

	$baseAddress.Substring(0, $lastOctetIndex) + $lastOctet
}

function GetShortDomainName ([string] $domainName)
{ 
	$chunk0 = $domainName.Split('.', 2)[0];
	if ($chunk0.Length -gt 15)
	{
		$chunk0.Substring(0, 15)
	}
	else
	{
		$chunk0
	}
}
