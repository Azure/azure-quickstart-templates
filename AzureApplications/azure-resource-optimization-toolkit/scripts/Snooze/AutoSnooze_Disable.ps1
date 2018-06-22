<#
.SYNOPSIS  
 Disable AutoSnooze feature
.DESCRIPTION  
 Disable AutoSnooze feature
.EXAMPLE  
.\AutoSnooze_Disable.ps1 
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
    Write-Output "Performing the AutoSnooze Disable..."

    Write-Output "Collecting all the schedule names for AutoSnooze..."

    #---------Read all the input variables---------------
    $SubId = Get-AutomationVariable -Name 'Internal_AzureSubscriptionId'
    $ResourceGroupNames = Get-AutomationVariable -Name 'External_ResourceGroupNames'
    $automationAccountName = Get-AutomationVariable -Name 'Internal_AROautomationAccountName'
    $aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

    $webhookUri = Get-AutomationVariable -Name 'Internal_AutoSnooze_WebhookUri'
    $scheduleNameforCreateAlert = "Schedule_AutoSnooze_CreateAlert_Parent"

    Write-Output "Disabling the schedules for AutoSnooze..."

    #Disable the schedule for AutoSnooze
    Set-AzureRmAutomationSchedule -automationAccountName $automationAccountName -Name $scheduleNameforCreateAlert -ResourceGroupName $aroResourceGroupName -IsEnabled $false

    Write-Output "Disabling the alerts on all the VM's configured as per asset variable..."

    [string[]] $VMRGList = $ResourceGroupNames -split ","

    $AzureVMListTemp = $null
    $AzureVMList=@()
    ##Getting VM Details based on RG List or Subscription
    if($VMRGList -ne $null)
    {
        foreach($Resource in $VMRGList)
        {
            Write-Output "Validating the resource group name ($($Resource.Trim()))" 
            $checkRGname = Get-AzureRmResourceGroup  $Resource.Trim() -ev notPresent -ea 0  
            if ($checkRGname -eq $null)
            {
                Write-Warning "$($Resource) is not a valid Resource Group Name. Please Verify!"
				Write-Output "$($Resource) is not a valid Resource Group Name. Please Verify!"
            }
            else
            {                   
				$AzureVMListTemp = Get-AzureRmVM -ResourceGroupName $Resource -ErrorAction SilentlyContinue
				if($AzureVMListTemp -ne $null)
				{
					$AzureVMList+=$AzureVMListTemp
				}
            }
        }
    } 
    else
    {
        Write-Output "Getting all the VM's from the subscription..."  
        $AzureVMList=Get-AzureRmVM -ErrorAction SilentlyContinue
    }

    Write-Output "Calling child runbook to disable the alert on all the VM's..."    

    foreach($VM in $AzureVMList)
    {
        try
        {
            $params = @{"VMObject"=$VM;"AlertAction"="Disable";"WebhookUri"=$webhookUri}                    
            $runbook = Start-AzureRmAutomationRunbook -automationAccountName $automationAccountName -Name 'AutoSnooze_CreateAlert_Child' -ResourceGroupName $aroResourceGroupName –Parameters $params
        }
        catch
        {
            Write-Output "Error Occurred on Alert disable..."   
            Write-Output $_.Exception 
        }
    }

    Write-Output "AutoSnooze disable execution completed..."

}
catch
{
    Write-Output "Error Occurred on AutoSnooze Disable Wrapper..."   
    Write-Output $_.Exception
}