<#
.SYNOPSIS  
 Runbook for shutdown the Azure VM based on CPU usage
.DESCRIPTION  
 Runbook for shutdown the Azure VM based on CPU usage
.EXAMPLE  
.\AutoSnooze_CreateAlert_Parent.ps1 -WhatIf $false
Version History  
v1.0   - Initial Release  
#>

Param(
[Parameter(Mandatory=$false,HelpMessage="Enter the value for WhatIf. Values can be either true or false")][bool]$WhatIf = $false
)

function CheckExcludeVM ($FilterVMList)
{
    
    $AzureVM= Get-AzureRmVM -ErrorAction SilentlyContinue
    [boolean] $ISexists = $false
            
    [string[]] $invalidvm=@()
    $ExAzureVMList=@()

    foreach($filtervm in $VMfilterList)
    {
        foreach($vmname in $AzureVM)
        {
            if($Vmname.Name.ToLower().Trim() -eq $filtervm.Tolower().Trim())
            {                    
                $ISexists = $true
                $ExAzureVMList+=$vmname
                break                    
            }
            else
            {
                $ISexists = $false
            }
        }
        if($ISexists -eq $false)
        {
            $invalidvm = $invalidvm+$filtervm
        }
    }

    if($invalidvm -ne $null)
    {
        Write-Output "Runbook Execution Stopped! Invalid VM Name(s) in the exclude list: $($invalidvm) "
        Write-Warning "Runbook Execution Stopped! Invalid VM Name(s) in the exclude list: $($invalidvm) "
        exit
    }
    else
    {
        return $ExAzureVMList
    }
    
}

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


#---------Read all the input variables---------------
$SubId = Get-AutomationVariable -Name 'Internal_AzureSubscriptionId'
$ResourceGroupNames = Get-AutomationVariable -Name 'External_ResourceGroupNames'
$ExcludeVMNames = Get-AutomationVariable -Name 'External_ExcludeVMNames'
$automationAccountName = Get-AutomationVariable -Name 'Internal_AROautomationAccountName'
$aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

#-----Prepare the inputs for alert attributes-----
$webhookUri = Get-AutomationVariable -Name 'Internal_AutoSnooze_WebhookUri'

try
    {  
        Write-Output "Runbook Execution Started..."
        [string[]] $VMfilterList = $ExcludeVMNames -split ","
        [string[]] $VMRGList = $ResourceGroupNames -split ","

        #Validate the Exclude List VM's and stop the execution if the list contains any invalid VM
        if([string]::IsNullOrEmpty($ExcludeVMNames) -ne $true)
        {
            Write-Output "Exclude VM's added so validating the resource(s)..."            
            $ExAzureVMList = CheckExcludeVM -FilterVMList $VMfilterList
        } 

        if ($ExAzureVMList -ne $null -and $WhatIf -eq $false)
        {
            foreach($VM in $ExAzureVMList)
            {
                try
                {
                        Write-Output "Disabling the alert rules for VM : $($VM.Name)" 
                        $params = @{"VMObject"=$VM;"AlertAction"="Disable";"WebhookUri"=$webhookUri}                    
                        $runbook = Start-AzureRmAutomationRunbook -automationAccountName $automationAccountName -Name 'AutoSnooze_CreateAlert_Child' -ResourceGroupName $aroResourceGroupName –Parameters $params
                }
                catch
                {
                    $ex = $_.Exception
                    Write-Output $_.Exception 
                }
            }
        }
        elseif($ExAzureVMList -ne $null -and $WhatIf -eq $true)
        {
            Write-Output "WhatIf parameter is set to True..."
            Write-Output "What if: Performing the alert rules disable for the Exclude VM's..."
            Write-Output $ExcludeVMNames
        }

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
                    Write-Output "$($Resource) is not a valid Resource Group Name. Please Verify!"
                    Write-Warning "$($Resource) is not a valid Resource Group Name. Please Verify!"
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
        
        $ActualAzureVMList=@()
        if($VMfilterList -ne $null)
        {
            foreach($VM in $AzureVMList)
            {  
                ##Checking Vm in excluded list                         
                if($VMfilterList -notcontains ($($VM.Name)))
                {
                    $ActualAzureVMList+=$VM
                }
            }
        }
        else
        {
            $ActualAzureVMList = $AzureVMList
        }

        if($WhatIf -eq $false)
        {    
            foreach($VM in $ActualAzureVMList)
            {  
                    Write-Output "Creating alert rules for the VM : $($VM.Name)"
                    $params = @{"VMObject"=$VM;"AlertAction"="Create";"WebhookUri"=$webhookUri}                    
                    $runbook = Start-AzureRmAutomationRunbook -automationAccountName $automationAccountName -Name 'AutoSnooze_CreateAlert_Child' -ResourceGroupName $aroResourceGroupName –Parameters $params
            }
            Write-Output "Note: All the alert rules creation are processed in parallel. Please check the child runbook (AutoSnooze_CreateAlert_Child) job status..."
        }
        elseif($WhatIf -eq $true)
        {
            Write-Output "WhatIf parameter is set to True..."
            Write-Output "When 'WhatIf' is set to TRUE, runbook provides a list of Azure Resources (e.g. VMs), that will be impacted if you choose to deploy this runbook."
            Write-Output "No action will be taken at this time..."
            Write-Output $($ActualAzureVMList) | Select-Object Name, ResourceGroupName | Format-List
        }
        Write-Output "Runbook Execution Completed..."
    }
    catch
    {
        $ex = $_.Exception
        Write-Output $_.Exception
    }
