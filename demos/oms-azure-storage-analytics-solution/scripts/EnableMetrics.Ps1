param([switch]$enablemetrics,[switch]$enablelogs,[switch]$filterbyRG,[switch]$filterbySA,[string]$filtermatchpattern)

#specify audited operations 

[array]$logOps=('Read','Write','Delete')

$services=@('Blob','Table','Queue','File')


If($enablemetrics)
{
# define metrics to enable on Storage Analytics

	$sacount=0
	$satracking=0


#region  Get classic Strorage Accounts

	IF($filterbySA)
	{
		$SAClassic=Get-AzureStorageAccount|where{$_.StorageAccountName -match $filtermatchpattern}
	}elseif(!$filterbyRG)
	{
		$SAClassic=Get-AzureStorageAccount
	}

	IF($SAClassic)
	{

		foreach($obj in $SAClassic)
		{
			# check and enable storage metircs 
			$sacount++
			
			Foreach ($svc in $services)
			{
				IF(  (Get-AzureStorageServiceMetricsProperty -ServiceType $svc  -MetricsType Minute -Context $obj.Context).MetricsLevel.value__ -eq 0)
				{
					Set-AzureStorageServiceMetricsProperty -MetricsType Minute -ServiceType $svc  -MetricsLevel ServiceAndApi -RetentionDays 1 -Context $obj.Context
					Write-host "Enabling Minute Metrics for $svc  on  $($obj.StorageAccountName)"
					$satracking++
				}

			}
		}

	}
#endregion



#region Get ARM based Storage Accounts




	IF($filterbySA)
	{
		$SAArm=Get-AzureRmStorageAccount |where{$_.StorageAccountName -match $filtermatchpattern}
	}elseif($filterbyRG)
	{
		$SAArm=Get-AzureRmStorageAccount |where{$_.ResourceGroupName -match $filtermatchpattern}
	}else{
		$SAArm=Get-AzureRmStorageAccount 
	}

	$obj=$null

	IF($SAArm)
	{
		foreach($obj in $SAArm)
		{
			$sacount++
			Foreach ($svc in $services)
			{
				IF(  (Get-AzureStorageServiceMetricsProperty -ServiceType $svc  -MetricsType Minute -Context $obj.Context).MetricsLevel.value__ -eq 0)
				{
					Set-AzureStorageServiceMetricsProperty -MetricsType Minute -ServiceType $svc  -MetricsLevel ServiceAndApi -RetentionDays 1 -Context $obj.Context
					Write-host "Enabling Minute Metrics for $svc  on  $($obj.StorageAccountName)"
					$satracking++
				}

			}
		}
	}

#endregion

	"$sacount storage accounts processed , $satracking  metrics enabled."

}

If ($enablelogs)
{


	$sacount=0
	$satracking=0


#ARM SA
	IF($filterbySA)
	{
		$SAArm=Get-AzureRmStorageAccount |where{$_.StorageAccountName -match $filtermatchpattern}
	}elseif($filterbyRG)
	{
		$SAArm=Get-AzureRmStorageAccount |where{$_.ResourceGroupName -match $filtermatchpattern} 
	}else{
		$SAArm=Get-AzureRmStorageAccount 
	}

	IF($SAArm)
	{
		foreach($obj in $SAArm)
		{
			$sacount++
			Foreach ($svc in $services|where{$_ -ne 'File'})
			{
				IF(  (Get-AzureStorageServiceLoggingProperty  -ServiceType $svc   -Context $obj.Context). LoggingOperations -eq 'None')
				{
					Set-AzureStorageServiceLoggingProperty -ServiceType $svc -Context $obj.Context -LoggingOperations $logops -RetentionDays 1 -Version 1.0

					Write-host "Enabling Logs  for $svc  on  $($obj.StorageAccountName)"
					$satracking++
				}

			}
		}
	}


	IF($filterbySA)
	{
		$SAClassic=Get-AzureStorageAccount|where{$_.StorageAccountName -match $filtermatchpattern}
	}elseif(!$filterbyRG)
	{
		$SAClassic=Get-AzureStorageAccount
	}

	IF($SAClassic)
	{

		foreach($obj in $SAClassic)
		{
			# check and enable storage metircs 
			$sacount++
			
			Foreach ($svc in $services|where{$_ -ne 'File'})
			{
				IF(  (Get-AzureStorageServiceLoggingProperty  -ServiceType $svc   -Context $obj.Context). LoggingOperations -eq 'None')
				{
					Set-AzureStorageServiceLoggingProperty -ServiceType $svc -Context $obj.Context -LoggingOperations $logops -RetentionDays 1 -Version 1.0

					Write-host "Enabling Logs  for $svc  on  $($obj.StorageAccountName)"
					$satracking++
				}

			}
		}

	}






}




