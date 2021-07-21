param (
[Parameter(Mandatory=$false)][string]$Currency   ,
[Parameter(Mandatory=$false)][string]$Locale   ,
[Parameter(Mandatory=$false)][string]$RegionInfo   ,
[Parameter(Mandatory=$false)][string]$OfferDurableId ,
[Parameter(Mandatory=$false)][bool]$propagatetags=$true,
[Parameter(Mandatory=$false)][string]$syncInterval ,
[Parameter(Mandatory=$false)] [bool] $clearLocks=$false                
)
#region Login to Azure account and select the subscription.
#Authenticate to Azure with SPN section
Write-Verbose "Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
# retry
$retry = 6
$syncOk = $false
do
{ 
	try
	{  
		Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
		$syncOk = $true
	}
	catch
	{
		$ErrorMessage = $_.Exception.Message
		$StackTrace = $_.Exception.StackTrace
		Write-Warning "Error during sync: $ErrorMessage, stack: $StackTrace. Retry attempts left: $retry"
		$retry = $retry - 1       
		Start-Sleep -s 60        
	}
} while (-not $syncOk -and $retry -ge 0)
Write-Verbose "Selecting Azure subscription..."
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 
#endregion
#define variables 
$AAResourceGroup = Get-AutomationVariable -Name 'AzureUsage-AzureAutomationResourceGroup-MS-Mgmt'
$AAAccount = Get-AutomationVariable -Name 'AzureUsage-AzureAutomationAccount-MS-Mgmt'
$RunbookName = "AzureUsage-MS-Mgmt"
$ScheduleName = "AzureUsage-Scheduler-$syncInterval"
$schedulerrunbookname="AzureUsage-Schedules-MS-Mgmt"
#create new variales and schedules
$RunbookStartTime = $Date = $([DateTime]::Now.AddMinutes(10))
IF($syncInterval -eq 'Hourly')
{
	$RunbookScheduleTime=(get-date   -Minute 2 -Second 0).addhours(1)
	if ($RunbookStartTime -gt $RunbookScheduleTime)
	{
		$RunbookScheduleTime=(get-date   -Minute 2 -Second 0).addhours(2)
	}
	$interval=1
	
}Else
{
	$RunbookScheduleTime=(get-date  -Hour 0 -Minute 0 -Second 0).adddays(1).AddHours(2)
	$interval=24
}
$checkschdl=@(get-AzureRmAutomationScheduledRunbook -RunbookName $RunbookName -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup)
If ([string]::IsNullOrEmpty($checkschdl))
{
	$sch=$null
	$RBsch=Get-AzureRmAutomationSchedule -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup|where{$_.name -match $ScheduleName}
	IF($RBsch)
	{
		foreach ($sch in $RBsch)
		{
			Remove-AzureRmAutomationSchedule -AutomationAccountName $AAAccount -Name $sch.Name -ResourceGroupName $AAResourceGroup -Force -ea 0
			
		}
	}
}
Write-Verbose "Creating $syncInterval schedule "
$params= @{"Currency"=$Currency ;"Locale"=$Locale;"RegionInfo" = $RegionInfo;OfferDurableId=$OfferDurableId;propagatetags=$propagatetags;syncInterval=$syncInterval}
$Count = 0
Write-Verbose "Creating schedule $ScheduleName for $RunbookScheduleTime for runbook $RunbookName"
$Schedule = New-AzureRmAutomationSchedule -Name "$ScheduleName" -StartTime $RunbookScheduleTime -HourInterval $interval -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
$Sch = Register-AzureRmAutomationScheduledRunbook -RunbookName $RunbookName -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup -ScheduleName $ScheduleName -Parameters $params
Start-AzureRmAutomationRunbook -AutomationAccountName $AAAccount -Name $RunbookName -ResourceGroupName $AAResourceGroup -Parameters $params
