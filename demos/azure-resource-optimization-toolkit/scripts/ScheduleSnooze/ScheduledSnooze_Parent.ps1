<#
.SYNOPSIS  
 Wrapper script for get all the VM's in all RG's or subscription level and then call the Start or Stop runbook
.DESCRIPTION  
 Wrapper script for get all the VM's in all RG's or subscription level and then call the Start or Stop runbook
.EXAMPLE  
.\ScheduledSnooze_Parent.ps1 -Action "Value1" -WhatIf "False"
Version History  
v1.0   - Initial Release  
#>
Param(
    [Parameter(Mandatory = $true, HelpMessage = "Enter the value for Action. Values can be either stop or start")][String]$Action,
    [Parameter(Mandatory = $false, HelpMessage = "Enter the value for WhatIf. Values can be either true or false")][bool]$WhatIf = $false
)

function ScheduleSnoozeAction ($VMObject, [string]$Action) {
    
    Write-Output "Calling the ScheduledSnooze_Child wrapper (Action = $($Action))..."
    if ($Action.ToLower() -eq 'start') {
        $params = @{"VMName" = "$($VMObject.Name)"; "Action" = "start"; "ResourceGroupName" = "$($VMObject.ResourceGroupName)" }   
    }    
    elseif ($Action.ToLower() -eq 'stop') {
        $params = @{"VMName" = "$($VMObject.Name)"; "Action" = "stop"; "ResourceGroupName" = "$($VMObject.ResourceGroupName)" }                    
    }    

    Write-Output "Performing the schedule $($Action) for the VM : $($VMObject.Name)"
    $runbook = Start-AzureRmAutomationRunbook -automationAccountName $automationAccountName -Name 'ScheduledSnooze_Child' -ResourceGroupName $aroResourceGroupName –Parameters $params
}

function CheckExcludeVM ($FilterVMList) {
    $AzureVM = Get-AzureRmVM -ErrorAction SilentlyContinue
    [boolean] $ISexists = $false
            
    [string[]] $invalidvm = @()
    $ExAzureVMList = @()

    foreach ($filtervm in $VMfilterList) {
        foreach ($vmname in $AzureVM) {
            if ($Vmname.Name.ToLower().Trim() -eq $filtervm.Tolower().Trim()) {                    
                $ISexists = $true
                $ExAzureVMList += $vmname
                break                    
            }
            else {
                $ISexists = $false
            }
        }
        if ($ISexists -eq $false) {
            $invalidvm = $invalidvm + $filtervm
        }
    }
    if ($invalidvm -ne $null) {
        Write-Output "Runbook Execution Stopped! Invalid VM Name(s) in the exclude list: $($invalidvm) "
        Write-Warning "Runbook Execution Stopped! Invalid VM Name(s) in the exclude list: $($invalidvm) "
        exit
    }
    else {
        Write-Output "Exclude VM's validation completed..."
    }    
}

#-----L O G I N - A U T H E N T I C A T I O N-----
$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


#---------Read all the input variables---------------
$SubId = Get-AutomationVariable -Name 'Internal_AzureSubscriptionId'
$ResourceGroupNames = Get-AutomationVariable -Name 'External_ResourceGroupNames'
$ExcludeVMNames = Get-AutomationVariable -Name 'External_ExcludeVMNames'
$automationAccountName = Get-AutomationVariable -Name 'Internal_AROautomationAccountName'
$aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

try {  
    $Action = $Action.Trim().ToLower()

    if (!($Action -eq "start" -or $Action -eq "stop")) {
        Write-Output "`$Action parameter value is : $($Action). Value should be either start or stop!"
        Write-Output "Completed the runbook execution..."
        exit
    }            
    Write-Output "Runbook Execution Started..."
    [string[]] $VMfilterList = $ExcludeVMNames -split ","
    [string[]] $VMRGList = $ResourceGroupNames -split ","

    #Validate the Exclude List VM's and stop the execution if the list contains any invalid VM
    if ([string]::IsNullOrEmpty($ExcludeVMNames) -ne $true) {
        Write-Output "Exclude VM's added so validating the resource(s)..."
        CheckExcludeVM -FilterVMList $VMfilterList
    } 
    $AzureVMListTemp = $null
    $AzureVMList = @()
    ##Getting VM Details based on RG List or Subscription
    if ($VMRGList -ne $null) {
        foreach ($Resource in $VMRGList) {
            Write-Output "Validating the resource group name ($($Resource.Trim()))" 
            $checkRGname = Get-AzureRmResourceGroup -Name $Resource.Trim() -ev notPresent -ea 0  
            if ($checkRGname -eq $null) {
                Write-Warning "$($Resource) is not a valid Resource Group Name. Please Verify!"
            }
            else {                   
                Write-Output "Resource Group Exists..."
                $AzureVMListTemp = Get-AzureRmVM -ResourceGroupName $Resource -ErrorAction SilentlyContinue
                if ($AzureVMListTemp -ne $null) {
                    $AzureVMList += $AzureVMListTemp
                }
            }
        }
    } 
    else {
        Write-Output "Getting all the VM's from the subscription..."  
        $AzureVMList = Get-AzureRmVM -ErrorAction SilentlyContinue
    }

    $ActualAzureVMList = @()
    if ($VMfilterList -ne $null) {
        foreach ($VM in $AzureVMList) {  
            ##Checking Vm in excluded list                         
            if ($VMfilterList -notcontains ($($VM.Name))) {
                $ActualAzureVMList += $VM
            }
        }
    }
    else {
        $ActualAzureVMList = $AzureVMList
    }

    Write-Output "The current action is $($Action)"
        
    if ($WhatIf -eq $false) {    
                
        foreach ($VM in $ActualAzureVMList) {  
            ScheduleSnoozeAction -VMObject $VM -Action $Action
        }
    }
    elseif ($WhatIf -eq $true) {
        Write-Output "WhatIf parameter is set to True..."
        Write-Output "When 'WhatIf' is set to TRUE, runbook provides a list of Azure Resources (e.g. VMs), that will be impacted if you choose to deploy this runbook."
        Write-Output "No action will be taken at this time..."
        Write-Output $($ActualAzureVMList) | Select-Object Name, ResourceGroupName | Format-List
    }
    Write-Output "Runbook Execution Completed..."
}
catch {
    $ex = $_.Exception
    Write-Output $_.Exception
}
