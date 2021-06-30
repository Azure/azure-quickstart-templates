<#
.Synopsis
   Runbook for automated IaaS VM Backup in Azure using Backup and Site Recovery (OMS)
.DESCRIPTION
   This Runbook will enable Backup on existing Azure IaaS VMs.
   You need to provide input to the Resource Group name that contains the Backup and Site Recovery (OMS) Resourcem the name of the recovery vault, 
   Fabric type, preferred policy and the template URI where the ARM template is located. Have fun!
#>

$credential = Get-AutomationPSCredential -Name 'AzureCredentials'
$subscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionID'
$OMSWorkspaceId = Get-AutomationVariable -Name 'OMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'
$OMSWorkspaceName = Get-AutomationVariable -Name 'OMSWorkspaceName'
$OMSResourceGroupName = Get-AutomationVariable -Name 'OMSResourceGroupName'
$TemplateUri='https://raw.githubusercontent.com/krnese/AzureDeploy/master/OMS/MSOMS/AzureIaaSBackup/azuredeploy.json'
$OMSRecoveryVault = Get-AutomationVariable -Name 'OMSRecoveryVault'

$ErrorActionPreference = 'Stop'

Try {
        Login-AzureRmAccount -credential $credential
        Select-AzureRmSubscription -SubscriptionId $subscriptionId

    }

Catch {
        $ErrorMessage = 'Login to Azure failed.'
        $ErrorMessage += " `n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
      }

Try {

        $Location = Get-AzureRmRecoveryServicesVault -Name $OMSRecoveryVault -ResourceGroupName $OMSResourceGroupName | select -ExpandProperty Location
    }

Catch {
        $ErrorMessage = 'Failed to retrieve the OMS Recovery Location property'
        $ErrorMessage += "`n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
      }

Try {
        $VMs = Get-AzureRmVM | Where-Object {$_.Location -eq $Location}
    }

Catch {
        $ErrorMessage = 'Failed to retrieve the VMs.'
        $ErrorMessage += "`n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
      }

# Enable Backup

Try {
        Foreach ($vm in $vms)
        {
            New-AzureRmResourceGroupDeployment -Name $vm.name `
                                               -ResourceGroupName $OMSResourceGroupName `
                                               -TemplateUri $TemplateUri `
                                               -omsRecoveryResourceGroupName $OMSResourceGroupName `
                                               -vmResourceGroupName $vm.ResourceGroupName `
                                               -vaultName $OMSRecoveryVault `
                                               -vmName $vm.name `
                                               -Verbose
        }
    }

Catch {
        $ErrorMessage = 'Failed to enable backup using ARM template.'
        $ErrorMessage += "`n"
        $ErrorMessage += 'Error: '
        $ErrorMessage += $_
        Write-Error -Message $ErrorMessage `
                    -ErrorAction Stop
      }




