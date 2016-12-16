# This resource waits for the existence of a SQL instance on a specified server.
#

function Get-TargetResource
{
	param
	(
		[parameter(Mandatory)] [string] $ServerName,
		[parameter(Mandatory)] [string] $InstanceName,
		[Parameter(Mandatory)] [PSCredential] $SqlUser,

		[ValidateRange(0, [int]::MaxValue)] [int] $MaximumWaitMinutes = 5, 
		[ValidateRange(5, [int]::MaxValue)] [int] $WaitIntervalSeconds = 15
	)

	@{
		ServerName = $ServerName
		InstanceName = $InstanceName
		SqlUser = $SqlUser.UserName
		MaximumWaitMinutes = $MaximumWaitMinutes
		WaitIntervalSeconds = $WaitIntervalSeconds
	}
}

function Set-TargetResource
{
	param
	(
		[parameter(Mandatory)] [string] $ServerName,
		[parameter(Mandatory)] [string] $InstanceName,
		[Parameter(Mandatory)] [PSCredential] $SqlUser,

		[ValidateRange(0, [int]::MaxValue)] [int] $MaximumWaitMinutes = 5, 
		[ValidateRange(5, [int]::MaxValue)] [int] $WaitIntervalSeconds = 15
	)

	$endTime = (Get-Date).AddMinutes($MaximumWaitMinutes)

	[bool] $testResult = $false
	do {
		$thisInterval = [Math]::Min($WaitIntervalSeconds, [int]($endTime - (get-date)).TotalSeconds)
		if ($thisInterval -gt 0)
		{
			# wait first and then test because LCM always calls Test-TargetResource first
			Write-Verbose -Message "Sleeping for $thisInterval seconds."
			Start-Sleep -Seconds $thisInterval
		}

		$testResult = Test-SqlInstance $ServerName $InstanceName -Credential $SqlUser
	} while (-not $testResult -and (Get-Date) -lt $endTime)

	if (-not $testResult)
	{
		throw "Failed to connect to instance '$ServerName\$InstanceName' within $MaximumWaitMinutes minutes."
	}
}

function Test-TargetResource
{
	param
	(
		[parameter(Mandatory)] [string] $ServerName,
		[parameter(Mandatory)] [string] $InstanceName,
		[Parameter(Mandatory)] [PSCredential] $SqlUser,

		[ValidateRange(0, [int]::MaxValue)] [int] $MaximumWaitMinutes = 5, 
		[ValidateRange(5, [int]::MaxValue)] [int] $WaitIntervalSeconds = 15
	)

	Test-SqlInstance $ServerName $InstanceName -Credential $SqlUser
}

#.SYNOPSIS
# Tests whether a SQL Server instance is connectable. 
function Test-SqlInstance
{
	param	(
		[parameter(Mandatory)] [string] $ServerName = $env:COMPUTERNAME,
		[parameter(Mandatory)] [string] $InstanceName = 'MSSQLSERVER',
		[parameter(Mandatory)] [PSCredential] $Credential
	)

	[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') | Out-Null

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

	# must always be less than the resource parameter $WaitIntervalSeconds
	$conn.ConnectTimeout = 2

	try
	{
		Write-Verbose -Message "Attempting connection to instance '$ServerName\$InstanceName'."
		$conn.Connect()
		$conn.Disconnect()
		$true
	}
	catch
	{
		$false
	}
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
