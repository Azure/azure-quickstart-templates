param ($collectAuditLogs,$collectionFromAllSubscriptions)

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

$AAResourceGroup = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA'
$AAAccount = Get-AutomationVariable -Name 'AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA'
$MetricsRunbookName = "AzureSAIngestionMetrics-MS-Mgmt-SA"
$MetricsScheduleName = "AzureStorageMetrics-Schedule"
$LogsRunbookName="AzureSAIngestionLogs-MS-Mgmt-SA"
$LogsScheduleName = "AzureStorageLogs-HourlySchedule"
$MetricsEnablerRunbookName = "AzureSAMetricsEnabler-MS-Mgmt-SA"
$MetricsEnablerScheduleName = "AzureStorageMetricsEnabler-DailySchedule"
$mainSchedulerName="AzureSA-Scheduler-Hourly"

$varText= "AAResourceGroup = $AAResourceGroup , AAAccount = $AAAccount"

Write-output $varText

#Inventory variables
$varVMIopsList="AzureSAIngestion-VM-IOPSLimits"

$vmiolimits=@{"Basic_A0"=300;
"Basic_A1"=300;
"Basic_A2"=300;
"Basic_A3"=300;
"Basic_A4"=300;
"ExtraSmall"=500;
"Small"=500;
"Medium"=500;
"Large"=500;
"ExtraLarge"=500;
"Standard_A0"=500;
"Standard_A1"=500;
"Standard_A2"=500;
"Standard_A3"=500;
"Standard_A4"=500;
"Standard_A5"=500;
"Standard_A6"=500;
"Standard_A7"=500;
"Standard_A8"=500;
"Standard_A9"=500;
"Standard_A10"=500;
"Standard_A11"=500;
"Standard_A1_v2"=500;
"Standard_A2_v2"=500;
"Standard_A4_v2"=500;
"Standard_A8_v2"=500;
"Standard_A2m_v2"=500;
"Standard_A4m_v2"=500;
"Standard_A8m_v2"=500;
"Standard_D1"=500;
"Standard_D2"=500;
"Standard_D3"=500;
"Standard_D4"=500;
"Standard_D11"=500;
"Standard_D12"=500;
"Standard_D13"=500;
"Standard_D14"=500;
"Standard_D1_v2"=500;
"Standard_D2_v2"=500;
"Standard_D3_v2"=500;
"Standard_D4_v2"=500;
"Standard_D5_v2"=500;
"Standard_D11_v2"=500;
"Standard_D12_v2"=500;
"Standard_D13_v2"=500;
"Standard_D14_v2"=500;
"Standard_D15_v2"=500;
"Standard_DS1"=3200;
"Standard_DS2"=6400;
"Standard_DS3"=12800;
"Standard_DS4"=25600;
"Standard_DS11"=6400;
"Standard_DS12"=12800;
"Standard_DS13"=25600;
"Standard_DS14"=51200;
"Standard_DS1_v2"=3200;
"Standard_DS2_v2"=6400;
"Standard_DS3_v2"=12800;
"Standard_DS4_v2"=25600;
"Standard_DS5_v2"=51200;
"Standard_DS11_v2"=6400;
"Standard_DS12_v2"=12800;
"Standard_DS13_v2"=25600;
"Standard_DS14_v2"=51200;
"Standard_DS15_v2"=64000;
"Standard_F1"=500;
"Standard_F2"=500;
"Standard_F4"=500;
"Standard_F8"=500;
"Standard_F16"=500;
"Standard_F1s"=3200;
"Standard_F2s"=6400;
"Standard_F4s"=12800;
"Standard_F8s"=25600;
"Standard_F16s"=51200;
"Standard_G1"=500;
"Standard_G2"=500;
"Standard_G3"=500;
"Standard_G4"=500;
"Standard_G5"=500;
"Standard_GS1"=5000;
"Standard_GS2"=10000;
"Standard_GS3"=20000;
"Standard_GS4"=40000;
"Standard_GS5"=80000;
"Standard_H8"=500;
"Standard_H16"=500;
"Standard_H8m"=500;
"Standard_H16m"=500;
"Standard_H16r"=500;
"Standard_H16mr"=500;
"Standard_NV6"=500;
"Standard_NV12"=500;
"Standard_NV24"=500;
"Standard_NC6"=500;
"Standard_NC12"=500;
"Standard_NC24"=500;
"Standard_NC24r"=500}

New-AzureRmAutomationVariable -Name $varVMIopsList -Description "Variable to store IOPS limits for Azure VM Sizes." -Value $vmiolimits -Encrypted 0 -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount  -ea 0

IF([string]::IsNullOrEmpty($AAAccount) -or [string]::IsNullOrEmpty($AAResourceGroup))
{

Write-Error "Automation Account  or Automation Account Resource Group Variables is empty. Make sure AzureSAIngestion-AzureAutomationAccount-MS-Mgmt-SA and AzureSAIngestion-AzureAutomationResourceGroup-MS-Mgmt-SA variables exist in automation account and populated. "
Write-Output "Script will not continue"
Exit


}


$min=(get-date).Minute 
if($min -in 0..10) 
{
    $RBStart1=(get-date -Minute 16 -Second 00).ToUniversalTime()
}Elseif($min -in 11..25) 
{
    $RBStart1=(get-date -Minute 31 -Second 00).ToUniversalTime()
}elseif($min -in 26..40) 
{
    $RBStart1=(get-date -Minute 46 -Second 00).ToUniversalTime()
}ElseIf($min -in 46..55) 
{
    $RBStart1=(get-date -Minute 01 -Second 00).AddHours(1).ToUniversalTime()
}Else
{
	$RBStart1=(get-date -Minute 16 -Second 00).AddHours(1).ToUniversalTime()
}

$RBStart2=$RBStart1.AddMinutes(15)
$RBStart3=$RBStart2.AddMinutes(15)
$RBStart4=$RBStart3.AddMinutes(15)


# First clean up any previous schedules to prevent any conflict 

$allSchedules=Get-AzureRmAutomationSchedule `
		-AutomationAccountName $AAAccount `
		-ResourceGroupName $AAResourceGroup

foreach ($sch in  $allSchedules|where{$_.Name -match $MetricsScheduleName -or $_.Name -match $MetricsEnablerScheduleName -or $_.Name -match $LogsScheduleName })
{

Write-output "Removing Schedule $($sch.Name)    "
Remove-AzureRmAutomationSchedule `
		-AutomationAccountName $AAAccount `
		-Force `
		-Name $sch.Name `
		-ResourceGroupName $AAResourceGroup `
    
} 

Write-output  "Creating schedule $MetricsScheduleName for runbook $MetricsRunbookName"

$i=1
Do {
    New-AzureRmAutomationSchedule `
		-AutomationAccountName $AAAccount `
		-HourInterval 1 `
		-Name $($MetricsScheduleName+"-$i") `
		-ResourceGroupName $AAResourceGroup `
		-StartTime (Get-Variable -Name RBStart"$i").Value

        IF ($collectionFromAllSubscriptions  -match 'Enabled')
        {
             $params = @{"collectionFromAllSubscriptions" = $true}
   
            Register-AzureRmAutomationScheduledRunbook `
		        -AutomationAccountName $AAAccount `
		        -ResourceGroupName  $AAResourceGroup `
		        -RunbookName $MetricsRunbookName `
		        -ScheduleName $($MetricsScheduleName+"-$i") -Parameters $Params
        }Else
        {
                Register-AzureRmAutomationScheduledRunbook `
		        -AutomationAccountName $AAAccount `
		        -ResourceGroupName  $AAResourceGroup `
		        -RunbookName $MetricsRunbookName `
		        -ScheduleName $($MetricsScheduleName+"-$i")
        }

    $i++
    }
While ($i -le 4)




#Create Schedule for collecting Logs
IF($collectAuditLogs -eq 'Enabled')
{

    #Add the schedule an hour ahead and start the runbook

    $RunbookStartTime = $Date =(get-date -Minute 05 -Second 00).AddHours(1).ToUniversalTime()
	IF (($runbookstarttime-(Get-date).ToUniversalTime()).TotalMinutes -lt 6)
	{
			$RunbookStartTime=((Get-date).ToUniversalTime()).AddMinutes(7)

	}
    Write-Output "Creating schedule $LogsScheduleName for $RunbookStartTime for runbook $LogsRunbookName"

New-AzureRmAutomationSchedule `
		-AutomationAccountName $AAAccount `
		-HourInterval 1 `
		-Name $LogsScheduleName `
		-ResourceGroupName $AAResourceGroup `
		-StartTime $RunbookStartTime

        IF ($collectionFromAllSubscriptions  -match 'Enabled')
        {
             $params = @{"collectionFromAllSubscriptions" = $true}
            Register-AzureRmAutomationScheduledRunbook `
		-AutomationAccountName $AAAccount `
		-ResourceGroupName  $AAResourceGroup `
		-RunbookName $LogsRunbookName `
		-ScheduleName $LogsScheduleName -Parameters $Params

             Start-AzureRmAutomationRunbook -AutomationAccountName $AAAccount -Name $LogsRunbookName -ResourceGroupName $AAResourceGroup -Parameters $Params | out-null
        }Else
        {
              Register-AzureRmAutomationScheduledRunbook `
		-AutomationAccountName $AAAccount `
		-ResourceGroupName  $AAResourceGroup `
		-RunbookName $LogsRunbookName `
		-ScheduleName $LogsScheduleName

            Start-AzureRmAutomationRunbook -AutomationAccountName $AAAccount -Name $LogsRunbookName -ResourceGroupName $AAResourceGroup | out-null
        }

  

    
}

# Creating Schedules for enabling MEtrics

$MetricsRunbookStartTime = $Date = [DateTime]::Today.AddHours(2).AddDays(1)

Write-Output "Creating schedule $MetricsEnablerScheduleName for $MetricsRunbookStartTime for runbook $MetricsEnablerRunbookName"
  
      New-AzureRmAutomationSchedule `
		-AutomationAccountName $AAAccount `
		-DayInterval 1 `
		-Name "$MetricsEnablerScheduleName" `
		-ResourceGroupName $AAResourceGroup `
		-StartTime $MetricsRunbookStartTime


Register-AzureRmAutomationScheduledRunbook `
		-AutomationAccountName $AAAccount `
		-ResourceGroupName  $AAResourceGroup `
		-RunbookName $MetricsEnablerRunbookName `
		-ScheduleName "$MetricsEnablerScheduleName"
  
  
  <#
    $Schedule = New-AzureRmAutomationSchedule -Name " -StartTime $MetricsRunbookStartTime  -DayInterval 1  -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
    $Sch = Register-AzureRmAutomationScheduledRunbook -RunbookName $MetricsEnablerRunbookName -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup -ScheduleName "$MetricsScheduleName"
#>
#finally start the  MEtrics enabled runbook once to enable metrics asap

Start-AzureRmAutomationRunbook -Name $MetricsEnablerRunbookName -ResourceGroupName $AAResourceGroup -AutomationAccountName $AAAccount | out-null

#finally remove the schedule for the createschedules runbook as not needed if all schedules are in place

$allSchedules=Get-AzureRmAutomationSchedule `
		-AutomationAccountName $AAAccount `
		-ResourceGroupName $AAResourceGroup |where{$_.Name -match $MetricsScheduleName -or $_.Name -match $MetricsEnablerScheduleName -or $_.Name -match $LogsScheduleName }


If ($allSchedules.count -ge 5)
{
Write-output "Removing hourly schedule for this runbook as its not needed anymore  "
Remove-AzureRmAutomationSchedule `
		-AutomationAccountName $AAAccount `
		-Force `
		-Name $mainSchedulerName `
		-ResourceGroupName $AAResourceGroup `


}

    

