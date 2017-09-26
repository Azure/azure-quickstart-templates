<#
.SYNOPSIS  
 Wrapper script for start & stop AzureRM VM's
.DESCRIPTION  
 Wrapper script for start & stop AzureRM VM's
.EXAMPLE  
.\ScheduledSnooze_Child.ps1 -VMName "Value1" -Action "Value2" -ResourceGroupName "Value3" 
Version History  
v1.0   - Initial Release  
#>
param(
[string]$VMName = $(throw "Value for VMName is missing"),
[String]$Action = $(throw "Value for Action is missing"),
[String]$ResourceGroupName = $(throw "Value for ResourceGroupName is missing")
)

#----------------------------------------------------------------------------------
#---------------------LOGIN TO AZURE AND SELECT THE SUBSCRIPTION-------------------
#----------------------------------------------------------------------------------
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
    Write-Output "VM action is : $($Action)"
            
    if ($Action.Trim().ToLower() -eq "stop")
    {
        Write-Output "Stopping the VM : $($VMName)"

        $Status = Stop-AzureRmVM -Name $VMName -ResourceGroupName $ResourceGroupName -Force
        if($Status -eq $null)
        {
            Write-Output "Error occured while stopping the Virtual Machine."
        }
        else
        {
           Write-Output "Successfully stopped the VM $VMName"
        }
    }
    elseif($Action.Trim().ToLower() -eq "start")
    {
        Write-Output "Starting the VM : $($VMName)"

        $Status = Start-AzureRmVM -Name $VMName -ResourceGroupName $ResourceGroupName
        if($Status -eq $null)
        {
            Write-Output "Error occured while starting the Virtual Machine $($VMName)"
        }
        else
        {
            Write-Output "Successfully started the VM $($VMName)"
        }
    }      
    
}
catch
{
    Write-Output "Error Occurred..."
    Write-Output $_.Exception
}



