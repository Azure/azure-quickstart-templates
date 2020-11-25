<# 

This script attempts to remove a resource group by first removing all the things that prevent removing resource groups
- Locks, backup protection, geo-pairing, etc.
It is a living script as we keep finding more cases... if you find one please add it.

#>

param(
    [string][Parameter(mandatory=$true)] $ResourceGroupName
)

#remove the locks
Get-AzResourceLock -ResourceGroupName $ResourceGroupName -Verbose | Remove-AzResourceLock -Force -verbose

#Remove Recovery Services Vaults
$vaults = Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Verbose #-Name $VaultName 

foreach($vault in $vaults){
    Set-AzRecoveryServicesVaultContext -Vault $vault -Verbose
    $rcs = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -Verbose
    foreach ($c in $rcs) {
        $bi = Get-AzRecoveryServicesBackupItem -Container $c -WorkloadType AzureVM -Verbose
        Disable-AzRecoveryServicesBackupProtection -Item $bi -RemoveRecoveryPoints -Verbose -Force
    }
    Remove-AzRecoveryServicesVault -Vault $vault -Verbose
}


#Note that for SQL Backup vaults the sequence of steps are different and not supported in the AzureRM cmdlets - see the remove-vaults.ps1 script for these steps until we can rewrite this
<#From public documentation, I see following steps prior to Delete Vault:
Stop Protection with Delete backup data: https://docs.microsoft.com/en-us/azure/backup/backup-azure-delete-vault#delete-the-recovery-services-vault-by-force

$bkpItem = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureWorkload -WorkloadType MSSQL -Name "<backup item name>" -VaultId $targetVault.ID
Disable-AzRecoveryServicesBackupProtection -Item $bkpItem -VaultId $targetVault.ID -RemoveRecoveryPoints
Unregister SQL VM: https://docs.microsoft.com/en-us/azure/backup/backup-azure-sql-automation#unregister-sql-vm
$SQLContainer = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVMAppContainer -FriendlyName <VM name> -VaultId $targetvault.ID
Unregister-AzRecoveryServicesBackupContainer -Container $SQLContainer -VaultId $targetvault.ID
ïƒ˜	Backup item name = msdb
ïƒ˜	VM name = sqlvmbackupdemo

foreach($vault in $vaults){
    $item = Get-AzRecoveryServicesBackupItem -BackupManagementType AzureWorkload -WorkloadType MSSQL -VaultId $vault.ID -Verbose
    Disable-AzRecoveryServicesBackupProtection -Item $item -VaultId $vault.ID -RemoveRecoveryPoints -Verbose -Force
    #Unregister SQL VM: https://docs.microsoft.com/en-us/azure/backup/backup-azure-sql-automation#unregister-sql-vm
    $SQLContainer = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVMAppContainer -VaultId $vault.ID #-FriendlyName <VM name>
    Unregister-AzRecoveryServicesBackupContainer -Container $SQLContainer -VaultId $vault.ID

}
#>

<#
remove disasterRecovery pairing on eventhub namespaces and service bus namespaces - no way to do this in PowerShell that we know of...
 Get-AzureRmEventHubNamespace | ft id
 >>first list the pairing (will need to get the namespaces from the resourceGroup)
 armclient GET /subscriptions/f42b4319-067a-4548-a650-33a1553b3a42/resourceGroups/qstci-c0749fa2-188e-8cef-ef73-7c2f7812a5e6/providers/Microsoft.EventHub/namespaces/ci1019f5770/disasterRecoveryConfigs?api-version=2017-04-01
 >>then break the pairing - this must be done on the primary namespace, no idea how you tell beforehand... check the partnerNamespace property and the role property on the GET in the previous step
 armclient POST /subscriptions/f42b4319-067a-4548-a650-33a1553b3a42/resourceGroups/qstci-c0749fa2-188e-8cef-ef73-7c2f7812a5e6/providers/Microsoft.EventHub/namespaces/ci1019f5770/disasterRecoveryConfigs/ci267c7c80899644b4/breakPairing?api-version=2017-04-01
#>
$eventHubs = Get-AzEventHubNamespace -ResourceGroupName $ResourceGroupName -Verbose  #-Name $VaultName 

#first look at the primary namespaces and break pairing
foreach($eventHub in $eventHubs){
    $drConfig = Get-AzEventHubGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name -Verbose
    $drConfig
    if ($drConfig) {
        if ($drConfig.Role.ToString() -eq "Primary") { #there is a partner namespace, break the pair before removing
            Set-AzEventHubGeoDRConfigurationBreakPair -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name -Name $drConfig.Name
        }
    }
}

#now that pairing is removed we can remove primary and secondary configs
foreach($eventHub in $eventHubs){
    $drConfig = Get-AzEventHubGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name -Verbose

    #### DEBUG THIS: I think this can only be done on primary?  So need to handle the error - once config is removed resource can be deleted by job
    Remove-AzEventHubGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name $drConfig.Name -Verbose
}


#remove DR for servicebuses - this is not bug free bug seems to work (one of the cmdlets returns NotFound)
$serviceBusNamespaces = Get-AzServiceBusNamespace -ResourceGroupName $ResourceGroupName -Verbose

#first look at the primary namespaces and break pairing
foreach($s in $serviceBusNamespaces){

    $drConfig = Get-AzServiceBusGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $s.Name
    $drConfig
    if ($drConfig) {
        if ($drConfig.Role.ToString() -eq "Primary") { #there is a partner namespace, break the pair before removing
            Set-AzServiceBusGeoDRConfigurationBreakPair -ResourceGroupName $ResourceGroupName -Namespace $s.Name -Name $drConfig.Name
        }
    }
}

#now that pairing is removed we can remove primary and secondary configs
foreach($s in $serviceBusNamespaces){

    $drConfig = Get-AzServiceBusGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $s.Name
    if ($drConfig){
        Remove-AzServiceBusGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $s.Name -Name $drConfig.Name -Verbose
    }
    # ??? Remove-AzureRmServiceBusNamespace -ResourceGroupName $ResourceGroupName -Name $s.Name -Verbose
}

foreach($s in $serviceBusNamespaces){
    # set ErrorAction on this since it throws if there is no config (unlike the other cmdlets)
    $migrationConfig = Get-AzServiceBusMigration -ResourceGroupName $ResourceGroupName -Name $s.Name -ErrorAction SilentlyContinue
    if ($migrationConfig){
        Remove-AzServiceBusMigration -ResourceGroupName $ResourceGroupName -Name $s.Name -Verbose
    }
}

<#
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rg -Name $vnetName
$subnets = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet

foreach($subnet in $subnets){
    Remove-AzureRMResource -ResourceId "$($subnet.id)/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default" -Force
}
#>

#removing the link is async and takes a while, so remove the RG will likely still fail unless we want to wait - status takes a while to populate so polling will be hard
$redisCaches = Get-AzRedisCache -ResourceGroupName $ResourceGroupName -Verbose

foreach($r in $redisCaches){
    $link = Get-AzRedisCacheLink -Name $r.Name
    if ($link){
        $link | Remove-AzRedisCacheLink -Verbose
    }
}

#ACI create a subnet delegation that must be removed before the vnet can be deleted
$vnets = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Verbose

foreach($vnet in $vnets){
    foreach($subnet in $vnets.Subnets){
        $delegations = Get-AzDelegation -Subnet $subnet -Verbose
        foreach($d in $delegations){
            Write-Output "Removing VNet Delegation: $($d.name)"
            Remove-AzDelegation -Name $d.Name -Subnet $subnet -Verbose
        }
    }
}


#finally...
Remove-AzResourceGroup -Force -Verbose -Name $ResourceGroupName
