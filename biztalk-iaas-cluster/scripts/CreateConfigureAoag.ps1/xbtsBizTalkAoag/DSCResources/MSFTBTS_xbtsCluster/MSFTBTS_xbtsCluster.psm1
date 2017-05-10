# This resource creates a cluster with one or more Azure virtual machine nodes as members.
# It is meant for creating a cluster with Azure VMs, in which the cluster's IP address needs to be
# a non-routable address due to Azure networking limitations.
#
# xbtsCluster: DSC resource to create a Windows Failover Cluster. If the
# cluster does not exist, it will create one in the domain and assign a local
# link address to the cluster. Then, it will add all specified nodes to the
# cluster.
#
# Adapted from:
# ~\sqlvm-alwayson-cluster\scripts\CreateFailoverCluster.ps1\xFailOverCluster\DSCResources\MicrosoftAzure_xCluster\MicrosoftAzure_xCluster.psm1
# Significant differences are:
#  * rely on automatic PsDscRunAsCredential in lieu of explicit $DomainAdministratorCredential
#

function Get-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $Name,

		[parameter(Mandatory = $false)]
		[string[]] $Nodes
	)

	$ComputerInfo = Get-WmiObject Win32_ComputerSystem
	if ($ComputerInfo -eq $null -or $ComputerInfo.Domain -eq $null)
	{
		throw "Can't find machine's domain name."
	}

	$cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain
	if (-not $cluster)
	{
		throw "Can't find the cluster '$Name'."
	}

	$nodeNames = $cluster | Get-ClusterNode -ErrorAction 'SilentlyContinue' -Verbose:$false | Select-Object -Expand Name

	@{
		Name = $Name
		Nodes = $nodeNames
	}
}

function Set-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $Name,

		[parameter(Mandatory)][ValidateCount(1,9)]
		[string[]] $Nodes
	)

	Write-Verbose -Message "Checking if cluster '$Name' is present ..."
	try
	{
		$ComputerInfo = Get-WmiObject Win32_ComputerSystem
		if ($ComputerInfo -eq $null -or $ComputerInfo.Domain -eq $null)
		{
			throw "Can't find machine's domain name."
		}

		$cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain
	}
	catch
	{
		$cluster = $null
	}

	if ($cluster)
	{
		$Name = $cluster.Name
		Write-Verbose -Message "Cluster '$Name' is present."
	}
	else
	{
		Write-Verbose -Message "Cluster '$Name' is NOT present."

		if ($env:COMPUTERNAME -notin $Nodes)
		{
			Write-Warning -Message "The local machine is not included in the set of nodes to include in the cluster; it will be included in the cluster."
		}

		$cluster = New-Cluster -Name $Name -Node $env:COMPUTERNAME -NoStorage -Force -ErrorAction Stop
		$Name = $cluster.Name

		Write-Verbose -Message "Successfully created cluster '$Name'."

		# See http://social.technet.microsoft.com/wiki/contents/articles/14776.how-to-configure-windows-failover-cluster-in-azure-for-alwayson-availability-groups.aspx
		# for why the following workaround is necessary.
		Write-Verbose -Message "Stopping the Cluster Name resource ..."
		$clusterGroup = $cluster | Get-ClusterGroup
		$clusterNameRes = $clusterGroup | Get-ClusterResource "Cluster Name"
		$clusterNameRes | Stop-ClusterResource | Out-Null

		Write-Verbose -Message "Stopping the Cluster IP Address resources ..."
		$clusterIpAddrRes = $clusterGroup | Get-ClusterResource |
				Where-Object 'ResourceType' -in 'IP Address', 'IPv6 Address', 'IPv6 Tunnel Address'
		$clusterIpAddrRes | Stop-ClusterResource | Out-Null

		Write-Verbose -Message "Removing all Cluster IP Address resources except the first IPv4 Address ..."
		$firstClusterIpv4AddrRes = $clusterIpAddrRes |
				Where-Object 'ResourceType' -eq 'IP Address' | Select-Object -First 1
		$clusterIpAddrRes | Where-Object 'Name' -ne $firstClusterIpv4AddrRes.Name |
				Remove-ClusterResource -Force | Out-Null

		Write-Verbose -Message "Setting the Cluster IP Address to a local link address ..."
		$firstClusterIpv4AddrRes | Set-ClusterParameter -ErrorAction Stop -Multiple @{
				"Address" = "169.254.1.1"
				"SubnetMask" = "255.255.0.0"
				"EnableDhcp" = 0
				"OverrideAddressMatch" = 1 }

		Write-Verbose -Message "Starting the Cluster Name resource ..."
		$clusterNameRes | Start-ClusterResource -ErrorAction Stop | Out-Null

		Write-Verbose -Message "Starting Cluster '$Name' ..."
		$cluster = Start-Cluster -Name $Name -ErrorAction Stop

		$cluster.SameSubnetThreshold = 20
	}

	$version = [Environment]::OSVersion.Version
	$nostorage = ($version.Major -gt 6) -or ($version.Major -eq 6 -and $version.Minor -ge 3)

	Write-Verbose -Message "Adding specified nodes to cluster '$Name' ..."
	$allNodes = Get-ClusterNode -Cluster $Name -ErrorAction 'SilentlyContinue' -Verbose:$false
	foreach ($nodeName in $Nodes)
	{
		$foundNode = $allNodes | Where-Object Name -eq $nodeName

		if ($foundNode -and ($foundNode.State -ne 'Up'))
		{
			Write-Verbose -Message "Removing node '$nodeName' since it's in the cluster but is not UP ..."
			$foundNode | Remove-ClusterNode -Cluster $Name -Force | Out-Null
		}
		elseif ($foundNode)
		{
			Write-Verbose -Message "Found node '$nodeName' already in the cluster."
			continue
		}

		if ($nostorage)
		{
			Write-Verbose -Message "Adding node '$nodeName' to the cluster, without storage (-NoStorage) ..."
			Add-ClusterNode -Name $nodeName -Cluster $Name -NoStorage -ErrorAction Stop | Out-Null
		}
		else
		{
			Write-Verbose -Message "Adding node '$nodeName' to the cluster ..."
			Add-ClusterNode -Name $nodeName -Cluster $Name -ErrorAction Stop | Out-Null
		}

		Write-Verbose -Message "Successfully added node '$nodeName' to cluster '$Name'."
	}
}

#.SYNOPSIS
# Tests for the existence of and nodes within a named cluster.
#.DESCRIPTION
# Tests for the following (in order):
#  1. Is the machine in a domain?
#  2. Does the cluster exist in the domain?
#  3. Are the expected nodes in the cluster's nodelist, and are they all up?
# Returns false if any of the above are false.
function Test-TargetResource
{
	param
	(
		[parameter(Mandatory)]
		[string] $Name,

		[parameter(Mandatory)][ValidateCount(1,9)]
		[string[]] $Nodes
	)

	$bRet = $false
	Write-Verbose -Message "Checking if cluster '$Name' is present ..."
	try
	{
		$ComputerInfo = Get-WmiObject Win32_ComputerSystem
		if ($ComputerInfo -eq $null -or $ComputerInfo.Domain -eq $null)
		{
			throw "Can't find machine's domain name."
		}

		$cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain
		if (-not $cluster)
		{
			Write-Verbose -Message "Cluster '$Name' is NOT present."
		}
		else
		{
			Write-Verbose -Message "Cluster '$Name' is present."
			Write-Verbose -Message "Checking if the expected nodes are in cluster '$Name' ..."
			$allNodes = Get-ClusterNode -Cluster $Name -ErrorAction 'SilentlyContinue' -Verbose:$false
			$bRet = $true
			foreach ($nodeName in $Nodes)
			{
				$foundNode = $allNodes | where-object Name -eq $nodeName
				if (-not $foundNode)
				{
					Write-Verbose -Message "Node '$nodeName' NOT found in the cluster."
					$bRet = $false
				}
				elseif ($foundNode.State -ne "Up")
				{
					Write-Verbose -Message "Node '$nodeName' found in the cluster, but is not UP."
					$bRet = $false
				}
				else
				{
					Write-Verbose -Message "Node '$nodeName' found in the cluster."
				}
			}

			if ($bRet)
			{
				Write-Verbose -Message "All expected nodes found in cluster '$Name'."
			}
			else
			{
				Write-Verbose -Message "At least one node is missing from cluster '$Name'."
			}
		}
	}
	catch
	{
		Write-Verbose -Message "Error testing cluster '$Name'."
		throw
	}

	$bRet
}

Export-ModuleMember -Function *-TargetResource
