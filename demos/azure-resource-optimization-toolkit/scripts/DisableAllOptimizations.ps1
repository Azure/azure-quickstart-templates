<#
.SYNOPSIS  
 Disable the ARO Toolkit 
.DESCRIPTION  
 Disable the ARO Toolkit
.EXAMPLE  
.\DisableAllOptimizations.ps1 
Version History  
v1.0   - Initial Release  
#>

#-----L O G I N - A U T H E N T I C A T I O N-----
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch 
{
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
try
{
    Write-Output "Performing AROToolkit Redbutton Abort..."

    Write-Output "Collecting all the schedule names for ScheduleSnooze and AutoSnooze..."

    #---------Read all the input variables---------------
    $SubId = Get-AutomationVariable -Name 'Internal_AzureSubscriptionId'
    $ResourceGroupNames = Get-AutomationVariable -Name 'External_ResourceGroupNames'
    $automationAccountName = Get-AutomationVariable -Name 'Internal_AROautomationAccountName'
    $aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

    #Schedules for AutoUpdate
    $autoUpdate = "Schedule_AROToolkit_AutoUpdate"        

    Write-Output "Disabling the Scheduleds for AROToolkit_AutoUpdate..."

    #Disable the Schedules for AROToolkit_AutoUpdate    
    Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $autoUpdate -ResourceGroupName $aroResourceGroupName -IsEnabled $false
    
    #Schedules for SequencedSnooze
    $sequencedStart = "SequencedSnooze-StartVM"
    $sequencedStop = "SequencedSnooze-StopVM"        

    Write-Output "Disabling the Scheduleds for SequencedSnooze..."

    #Disable the Schedules for ScheduleSnooze    
    Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequencedStart -ResourceGroupName $aroResourceGroupName -IsEnabled $false
    Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $sequencedStop -ResourceGroupName $aroResourceGroupName -IsEnabled $false

    #Schedules for ScheduleSnooze
    $scheduleStart = "ScheduledSnooze-StartVM"
    $scheduleStop = "ScheduledSnooze-StopVM"        

    Write-Output "Disabling the Schedules for ScheduleSnooze..."

    #Disable the Schedules for ScheduleSnooze    
    Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStart -ResourceGroupName $aroResourceGroupName -IsEnabled $false
    Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleStop -ResourceGroupName $aroResourceGroupName -IsEnabled $false

    Write-Output "Disabling the schedules & alerts for AutoSnooze..."

    #Disable the AutoSnooze by calling the AutoSnooze_Disable runbook
    Start-AzureRmAutomationRunbook -automationAccountName $automationAccountName -Name 'AutoSnooze_Disable' -ResourceGroupName $aroResourceGroupName -Wait

    Write-Output "AROToolkit Redbutton Abort execution completed..."

}
catch
{
    Write-Output "Error Occurred on executing AROToolkit Redbutton Abort..."   
    Write-Output $_.Exception
}
