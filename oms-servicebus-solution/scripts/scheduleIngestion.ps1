# Suspend the runbook if any errors, not just exceptions, are encountered
$ErrorActionPreference = "Stop"

#region Login to Azure account and select the subscription.
#Authenticate to Azure with SPN section
"Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
 Add-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID `
 -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

"Selecting Azure subscription..."
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 
#endregion

$AAResourceGroup = Get-AutomationVariable -name "AzureAutomationResourceGroup"
$AAAccount = Get-AutomationVariable -name "AzureAutomationAccount"
$RunbookName = "servicebusIngestion"
$ScheduleName = "servicebus"

$RunbookStartTime = $Date = $([DateTime]::Now.AddMinutes(10))

[int]$RunFrequency = 10
$NumberofSchedules = 60 / $RunFrequency
"$NumberofSchedules schedules will be created"

$Count = 0
While ($count -lt $NumberofSchedules)
{
    $count ++

    "Creating schedule $ScheduleName-$Count for $RunbookStartTime for runbook $RunbookName"
    $Schedule = New-AzureRmAutomationSchedule -Name "$ScheduleName-$Count" -StartTime $RunbookStartTime -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
    $Sch = Register-AzureRmAutomationScheduledRunbook -RunbookName $RunbookName -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup -ScheduleName "$ScheduleName-$Count"
    $RunbookStartTime = $RunbookStartTime.AddMinutes($RunFrequency)
}


Select-AzureRmSubscription -SubscriptionId "488940ab-71f4-4b40-86da-f5ab2ab4866e" -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"
$AAResourceGroup = "ServiceBusDevRG"    
$AAAccount = "SBautomation"
    $Schedule = New-AzureRmAutomationSchedule -Name "$ScheduleName" -StartTime $RunbookStartTime -HourInterval 1 -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup
    $Sch = Register-AzureRmAutomationScheduledRunbook -RunbookName $RunbookName -AutomationAccountName $AAAccount -ResourceGroupName $AAResourceGroup -ScheduleName "$ScheduleName"
    
