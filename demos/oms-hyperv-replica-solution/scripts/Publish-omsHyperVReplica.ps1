workflow Publish-omsHyperVReplica
{
	param(
		[Parameter(Mandatory=$true)]
		[string]
		$computerName
	)

	$OMSConnection = Get-AutomationConnection -Name 'omsHypervReplicaOMSConnection'
	$credential    = Get-AutomationPSCredential -Name 'omsHypervReplicaRunAsAccount'
	$omsRunNumber  = Get-AutomationVariable -Name 'omsHypervReplicaRunNumber'

	Write-Verbose 'Getting Run Number'
	$omsRunNumberIncrease = $omsRunNumber + 1
	Set-AutomationVariable -Name 'omsHypervReplicaRunNumber' -Value $omsRunNumberIncrease

	Write-Verbose 'Getting Replication Statistics From Hosts'

	ForEach -Parallel -throttlelimit 5 ($computer in ($computerName -split ';'))
	{
		$vms = InlineScript {
			Invoke-Command  -ScriptBlock {
				Measure-VMReplication -ReplicationMode Primary
			} -ComputerName $USING:computer -Credential $USING:credential
		}

		if($vms)
		{
			ForEach -Parallel ($vm in $vms)
			{
				$OMSDataInjection = @{
					OMSConnection     = $OMSConnection
					LogType           = 'hyperVReplica'
					UTCTimeStampField = 'LogTime'
					OMSDataObject     = [psCustomObject]@{
															name                      = $vm.name
															primaryServer             = $vm.primaryServerName
															replicaServer             = $vm.replicaServerName
															state                     = $vm.state
															health                    = $vm.health
															LastReplicationTime       = $vm.LastReplicationTime
															AverageReplicationSize    = $vm.AvgReplSize
															LogTime                   = [Datetime]::UtcNow
															runNumber                 = $omsRunNumber
														}
				}

				try
				{
					Write-Verbose "Uploading Data To OMS For VM $($vm.name)"
					New-OMSDataInjection @OMSDataInjection
				}
				catch
				{
					Write-Error $_
				}
			}
		}
		else
		{
			Write-Verbose 'No VMs are being replicated.'
		}
	}
}
