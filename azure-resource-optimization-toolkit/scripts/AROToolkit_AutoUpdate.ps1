<#
.SYNOPSIS  
 AutoUpdate Module for ARO Toolkit future releases
.DESCRIPTION  
 AutoUpdate Module for ARO Toolkit future releases
.EXAMPLE  
.\AROToolkit_AutoUpdate.ps1 
Version History  
v1.0   - <dev> - Initial Release  
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
    Write-Output "AutoUpdate Wrapper execution starts..."
    
    #Local Variables

    $GithubRootPath    = "https://raw.githubusercontent.com/Microsoft/MSITARM"
    $GithubBranch  = "__branch__"
    $ScriptPath    = "ARO-toolkit/scripts"
    $FileName = "AutoUpdateWorker.ps1"
    $GithubFullPath = "$($GithubRootPath)/$($GithubBranch)/$($ScriptPath)/$($FileName)"

    $AutomationAccountName = Get-AutomationVariable -Name 'Internal_AROAutomationAccountName'
    $aroResourceGroupName = Get-AutomationVariable -Name 'Internal_AROResourceGroupName'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

    $WebClient = New-Object System.Net.WebClient

    Write-Output "Download the AutoUpdateWorker script from Github..."

    $WebClient.DownloadFile($($GithubFullPath),"$PSScriptRoot\$($FileName)")    
    $psScriptPath = "$PSScriptRoot\$($FileName)"
    $RunbookName = $FileName.Substring(0,$FileName.Length-4).Trim()

    Write-Output "Creating the worker runbook in the Automation Account..." 

    New-AzureRmAutomationRunbook -Name $RunbookName -AutomationAccountName $AutomationAccountName -ResourceGroupName $aroResourceGroupName -Type PowerShell -Description "New autoupdate worker runbook"

    Import-AzureRmAutomationRunbook -AutomationAccountName $AutomationAccountName -ResourceGroupName $aroResourceGroupName -Path $psScriptPath -Name $RunbookName -Force -Type PowerShell 

    Write-Output "Publishing the new Runbook $($RunbookName)..."
    Publish-AzureRmAutomationRunbook -AutomationAccountName $AutomationAccountName -ResourceGroupName $aroResourceGroupName -Name $RunbookName

    Write-Output "Executing the new Runbook $($RunbookName)..."
    Start-AzureRmAutomationRunbook -Name $RunbookName -AutomationAccountName $AutomationAccountName -ResourceGroupName $aroResourceGroupName -Wait

    Write-Output "Runbook $($RunbookName) execution completed. Deleting the runbook..."
    Remove-AzureRmAutomationRunbook -Name $RunbookName -AutomationAccountName $AutomationAccountName -ResourceGroupName $aroResourceGroupName -Force 
    
    Write-Output "AutoUpdate Wrapper execution completed..."
}
catch
{
    Write-Output "Error Occurred in the AutoUpdate wrapper runbook..."
    Write-Output $_.Exception
}

