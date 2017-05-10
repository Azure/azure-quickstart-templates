#
# xbtsSqlAvailabilityGroupListener: DSC resource that configures a SQL AlwaysOn Availability Group Listener.
#
# Adapted from:
# ~\sqlvm-alwayson-cluster\scripts\CreateFailoverCluster.ps1\xSQL\DSCResources\MicrosoftAzure_xSqlAvailabilityGroupListener\MicrosoftAzure_xSqlAvailabilityGroupListener.psm1
# Significant differences are:
#  * rely on automatic PsDscRunAsCredential in lieu of explicit $DomainCredential
#  * enforce 15-char maximum for $Name (to comply with cluster-resource network name limit) 
#  * clarified support for named instances (similar to xbtsSqlAvailabilityGroup.psm1)
#  * drop $DomainNameFqdn parameter
#  * some clean-up of verbose output
#

function Get-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $InstanceName,

		[parameter(Mandatory)]
		[string] $AvailabilityGroupName,

		[parameter(Mandatory)] [ValidateLength(1, 15)]
		[string] $Name,

		[parameter(Mandatory)]
		[string] $IpAddress,

		[UInt32] $Port = 1433,

		[UInt32] $ProbePort = 59999,

		[Parameter(Mandatory)]
		[PSCredential] $SqlAdministrator
	)

	@{
		InstanceName = $InstanceName
		AvailabilityGroupName = $AvailabilityGroupName
		Name = $Name
		IpAddress = $IpAddress
		Port = $Port
		ProbePort = $ProbePort
		SqlAdministrator = $SqlAdministrator.UserName
	}
}

function Set-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $InstanceName,

		[parameter(Mandatory)]
		[string] $AvailabilityGroupName,

		[parameter(Mandatory)] [ValidateLength(1, 15)]
		[string] $Name,

		[parameter(Mandatory)]
		[string] $IpAddress,

		[UInt32] $Port = 1433,

		[UInt32] $ProbePort = 59999,

		[Parameter(Mandatory)]
		[PSCredential] $SqlAdministrator
	)

	# this is used near the end, but connect now presumably so if fails, an
	#  unhandled exception can terminate us immediately
	Write-Verbose -Message "Connecting to local SQL instance '$InstanceName' ..."
	$sqlLocal = Connect-SqlInstance $env:COMPUTERNAME $InstanceName -Credential $SqlAdministrator

	Write-Verbose -Message "Acquiring cluster resource '$AvailabilityGroupName' ..."
	$agResource = Get-ClusterResource -Name $AvailabilityGroupName -ErrorAction SilentlyContinue -Verbose:$false
	if (-not $agResource)
	{
		throw "Cluster resource for the availability group '$AvailabilityGroupName' could not be found; insure that the availability group has already been created."
	}
	if ($agResource.OwnerNode -ne $env:COMPUTERNAME)
	{
		# not sure this restriction is definitely required:
		throw 'Unable to create or modify availability group listener because this machine is not acting as the primary node of the cluster; this DSC resource must be executed on the primary node of the cluster.'
	}

	Write-Verbose -Message "Stopping cluster resource '$AvailabilityGroupName' ..."
	$agResource | Stop-ClusterResource | Out-Null
	$agResource = $null

	if (-not (Get-ClusterResource -Name $Name -ErrorAction SilentlyContinue -Verbose:$false))
	{
		Write-Verbose -Message "Creating Network Name cluster resource '$Name' ..."
		Add-ClusterResource -Name $Name -Group $AvailabilityGroupName -ResourceType 'Network Name' |
				Set-ClusterParameter -Multiple @{
					Name = $Name
					DnsName = $Name.ToLowerInvariant() }

		Write-Verbose -Message "Setting resource dependency between '$AvailabilityGroupName' and '$Name' ..."
		Set-ClusterResourceDependency -Resource $AvailabilityGroupName -Dependency "[$Name]"
	}

	if (-not (Get-ClusterResource "IP Address $IpAddress" -ErrorAction SilentlyContinue -Verbose:$false))
	{
		Write-Verbose -Message "Creating IP Address cluster resource '$IpAddress' ..."
		Add-ClusterResource -Name "IP Address $IpAddress" -Group $AvailabilityGroupName -ResourceType 'IP Address' |
				Set-ClusterParameter -Multiple @{
					Address = $IpAddress
					ProbePort = $ProbePort
					SubnetMask = '255.255.255.255'
					Network = (Get-ClusterNetwork)[0].Name
					OverrideAddressMatch = 1
					EnableDhcp = 0 }

		Write-Verbose -Message "Setting resource dependency between '$Name' and '$IpAddress' ..."
		Set-ClusterResourceDependency -Resource $Name -Dependency "[IP Address $IpAddress]"
	}

	# explicitly insure each resource is online, in reverse dependency order
	Write-Verbose -Message "Starting cluster resource 'IP Address $IpAddress' ..."
	Start-ClusterResource -Name "IP Address $IpAddress" | Out-Null

	Write-Verbose -Message "Starting cluster resource '$Name' ..."
	Start-ClusterResource -Name $Name | Out-Null

	Write-Verbose -Message "Starting cluster resource '$AvailabilityGroupName' ..."
	Start-ClusterResource -Name $AvailabilityGroupName | Out-Null

	Write-Verbose -Message "Setting the Availability Group Listener port to '$Port' ..."
	$ag = Find-SqlAvailabilityGroup -Name $AvailabilityGroupName -Server $sqlLocal
	$agListener = $ag.AvailabilityGroupListeners | Where-Object Name -eq $Name
	$agListener.PortNumber = $Port
	$agListener.Alter()
}

function Test-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $InstanceName,

		[parameter(Mandatory)]
		[string] $AvailabilityGroupName,

		[parameter(Mandatory)] [ValidateLength(1, 15)]
		[string] $Name,

		[parameter(Mandatory)]
		[string] $IpAddress,

		[UInt32] $Port = 1433,

		[UInt32] $ProbePort = 59999,

		[Parameter(Mandatory)]
		[PSCredential] $SqlAdministrator
	)

	Write-Verbose -Message "Checking if SQL AG '$AvailabilityGroupName' exists on instance '$InstanceName' ..."
	$sqlLocal = Connect-SqlInstance $env:COMPUTERNAME $InstanceName -Credential $SqlAdministrator
	if (Find-SqlAvailabilityGroup -Name $AvailabilityGroupName -Server $sqlLocal)
	{
		Write-Verbose -Message "SQL AG '$AvailabilityGroupName' found."
	}
	else
	{
		throw "SQL AG '$AvailabilityGroupName' NOT found."
	}

	[bool] $outcome = $true

	Write-Verbose -Message "Checking existence of Network Name cluster resource '$Name' ..."
	if (Get-ClusterResource -Name $Name -ErrorAction SilentlyContinue -Verbose:$false)
	{
		Write-Verbose -Message "Network Name cluster resource '$Name' found."
	}
	else
	{
		$outcome = $false
		Write-Verbose -Message "Network Name cluster resource '$Name' NOT found."
	}

	$ipaResName = "IP Address $IpAddress"
	Write-Verbose -Message "Checking existence of IP Address cluster resource '$ipaResName' ..."
	if (Get-ClusterResource -Name $ipaResName -ErrorAction SilentlyContinue -Verbose:$false)
	{
		Write-Verbose -Message "IP Address cluster resource '$ipaResName' found."
	}
	else
	{
		$outcome = $false
		Write-Verbose -Message "IP Address cluster resource '$ipaResName' NOT found."
	}

	# CONSIDER: check that each existing resource is online

	return $outcome
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
