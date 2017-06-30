<#
.SYNOPSIS  
 This runbook used to perform sequenced start or stop Azure RM VM
.DESCRIPTION  
 This runbook used to perform sequenced start or stop Azure RM VM
.EXAMPLE  
.\SequencedSnooze_Parent.ps1 -Action "Value1" 
Version History  
v1.0   - <Team-A> - Initial Release  
#>
Param(
[Parameter(Mandatory=$true,HelpMessage="Enter the value for Action. Values can be either stop or start")][String]$Action,
[Parameter(Mandatory=$false,HelpMessage="Enter the value for WhatIf. Values can be either true or false")][bool]$WhatIf = $false,
[Parameter(Mandatory=$false,HelpMessage="Enter the value for ContinueOnError. Values can be either true or false")][bool]$ContinueOnError = $false
)
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

function CheckVMState ($VMObject,[string]$Action)
{
    [bool]$IsValid = $false
    
    $CheckVMState = (Get-AzureRmVM -ResourceGroupName $VMObject.ResourceGroupName -Name $VMObject.Name -Status -ErrorAction SilentlyContinue).Statuses.Code[1]
    if($Action.ToLower() -eq 'start' -and $CheckVMState -eq 'PowerState/running')
    {
        $IsValid = $true
    }    
    elseif($Action.ToLower() -eq 'stop' -and $CheckVMState -eq 'PowerState/deallocated')
    {
            $IsValid = $true
    }    
    return $IsValid
}

#---------Read all the input variables---------------
$automationAccountName = Get-AutomationVariable -Name 'Internal_AROautomationAccountName'
$aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

try
{
    $Action = $Action.Trim().ToLower()

    if(!($Action -eq "start" -or $Action -eq "stop"))
    {
        Write-Output "`$Action parameter value is : $($Action). Value should be either start or stop!"
        Write-Output "Completed the runbook execution..."
        exit
    }
     
    Write-Output "Executing the Sequenced $($Action)..."   
    Write-Output "Input parameter values..."
    Write-Output "`$Action : $($Action)"
    Write-Output "`$WhatIf : $($WhatIf)"
    Write-Output "`$ContinueOnError : $($ContinueOnError)"
    Write-Output "Filtering the tags across all the VM's..."
    
    $tagValue = "sequence"    
    $TagKeys = Get-AzureRmVM | Where-Object {$_.Tags.Keys -eq $tagValue.ToLower()} | Select Tags
    $Sequences=[System.Collections.ArrayList]@()
    foreach($tag in $TagKeys.Tags)
    {
        if($tag.ContainsKey($tagValue))
        {
            [void]$Sequences.add([int]$tag.sequence)
        }
    }

    $Sequences = $Sequences | Sort-Object -Unique
    if($Action.ToLower() -eq 'start')
    {
        $Sequences = $Sequences | Sort -Descending
    }

    foreach($seq in $Sequences)
    {
        if($WhatIf -eq $false)
        {
            Write-Output "Performing the $($Action) for the sequence-$($seq) VM's..."
            $AzureVMList=Find-AzureRmResource -TagName $tagValue.ToLower() -TagValue $seq | Where-Object {$_.ResourceType -eq “Microsoft.Compute/virtualMachines”} | Select Name, ResourceGroupName
        
            foreach($vmObj in $AzureVMList)
            {                
                Write-Output "Performing the $($Action) action on VM: $($vmobj.Name)"
                $params = @{"VMName"="$($vmObj.Name)";"Action"=$Action;"ResourceGroupName"="$($vmObj.ResourceGroupName)"}                    
                Start-AzureRmAutomationRunbook -automationAccountName $automationAccountName -Name 'ScheduledSnooze_Child' -ResourceGroupName $aroResourceGroupName –Parameters $params                
            }

            Write-Output "Completed the sequenced $($Action) for the sequence-$($seq) VM's..."

            if(($Action -eq 'stop' -and $seq -ne $Sequences.Count) -or ($Action -eq 'start' -and $seq -ne [int]$Sequences.Count - ([int]$Sequences.Count-1)))
            {
                Write-Output "Validating the status before processing the next sequence..."
            }        

            foreach($vmObjStatus in $AzureVMList)
            {
                [int]$SleepCount = 0 
                $CheckVMStatus = CheckVMState -VMObject $vmObjStatus -Action $Action
                While($CheckVMStatus -eq $false)
                {                
                    Write-Output "Checking the VM Status in 10 seconds..."
                    Start-Sleep -Seconds 10
                    $SleepCount+=10
                    if($SleepCount -gt 600 -and $ContinueOnError -eq $false)
                    {
                        Write-Output "Unable to $($Action) the VM $($vmObjStatus.Name). ContinueOnError is set to False, hence terminating the sequenced $($Action)..."
                        Write-Output "Completed the sequenced $($Action)..."
                        exit
                    }
                    elseif($SleepCount -gt 600 -and $ContinueOnError -eq $true)
                    {
                        Write-Output "Unable to $($Action) the VM $($vmObjStatus.Name). ContinueOnError is set to True, hence moving to the next resource..."
                        break
                    }
                    $CheckVMStatus = CheckVMState -VMObject $vmObjStatus -Action $Action
                }
            }
        }
        elseif($WhatIf -eq $true)
        {
            Write-Output "WhatIf parameter is set to True..."
            Write-Output "When 'WhatIf' is set to TRUE, runbook provides a list of Azure Resources (e.g. VMs), that will be impacted if you choose to deploy this runbook."
            Write-Output "No action will be taken at this time..."
            $AzureVMList=Find-AzureRmResource -TagName $tagValue.ToLower() -TagValue $seq | Where-Object {$_.ResourceType -eq “Microsoft.Compute/virtualMachines”} | Select-Object Name, ResourceGroupName            
            Write-Output $($AzureVMList)
        }
    }
    Write-Output "Completed the sequenced $($Action)..."
}
catch
{
    Write-Output "Error Occurred in the sequence $($Action) runbook..."   
    Write-Output $_.Exception
}