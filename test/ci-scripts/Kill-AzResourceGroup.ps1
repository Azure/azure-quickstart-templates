<# 

This script attempts to remove a resource group by first removing all the things that prevent removing resource groups
- Locks, backup protection, geo-pairing, etc.
It is a living script as we keep finding more cases... if you find one please add it.

#>

param(
    [string][Parameter(mandatory = $true)] $ResourceGroupName
)

Write-Host "Kill: $resourceGroupName"

# Skip any resourceGroups in FF that have tried to deploy jobCollections - they can't be deleted
# ICM #
if ((Get-AzContext).Environment.Name -eq "AzureUSGovernment") {
    Write-Host "Running in FF..."
    $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName
    $ops = Get-AzResourceGroupDeploymentOperation -ResourceGroupName $ResourceGroupName -DeploymentName $deployment.DeploymentName
    foreach ($op in $ops) {
        if ($op.TargetResource -like "*/Microsoft.Scheduler/jobCollections/*") {
            Write-Host "Found operation with target resource: $($op.TargetResource)"
            exit
        }
    }
}
# End of Skip Code

$subscriptionId = $(Get-AzContext).Subscription.Id

#remove the locks
Get-AzResourceLock -ResourceGroupName $ResourceGroupName -Verbose | Remove-AzResourceLock -Force -verbose

#Remove Recovery Services Vaults
$vaults = Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Verbose

foreach ($vault in $vaults) {
    Write-Host "Recovery Services Vaults..."
    #Set-AzRecoveryServicesVaultContext -Vault $vault -Verbose - this is being deprecated use vaultId
    # disable softDelete
    Set-AzRecoveryServicesVaultProperty -VaultId $vault.ID -SoftDeleteFeatureState disable
    
    # Storage Backups
    $rcs = Get-AzRecoveryServicesBackupContainer -VaultId $vault.ID -ContainerType AzureStorage -Verbose
    foreach ($c in $rcs) {
        Write-Host "Recovery Services Vault Disable (storage)..."
        $bi = Get-AzRecoveryServicesBackupItem -VaultId $vault.ID -Container $c -WorkloadType AzureFiles -Verbose
        Disable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Item $bi -RemoveRecoveryPoints -Verbose -Force
        Unregister-AzRecoveryServicesBackupContainer -VaultId $vault.ID -Container $c -Verbose
    }
    
    #VM Backups
    $rcs = Get-AzRecoveryServicesBackupContainer -VaultId $vault.ID -ContainerType AzureVM -Verbose
    foreach ($c in $rcs) {
        Write-Host "Recovery Services Vault Disable (AzureVM)..."
        $bi = Get-AzRecoveryServicesBackupItem -VaultId $vault.ID -Container $c -WorkloadType AzureVM -Verbose
        Disable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Item $bi -RemoveRecoveryPoints -Verbose -Force
        Unregister-AzRecoveryServicesBackupContainer -VaultId $vault.ID -Container $c -Verbose
    }



    #Remove-AzRecoveryServicesVault -Vault $vault -Verbose
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

# Microsoft.DataProtection is not yet in AzureUSGovernment
if ((Get-AzContext).Environment.Name -eq "AzureCloud") {
    # The Az.DataProtection is not yet included with the rest of the Az module
    if ($(Get-Module -ListAvailable Az.DataProtection) -eq $null) {
        Write-Host "Installing Az.DataProtection module..."
        Install-Module Az.DataProtection -Force -AllowClobber #| Out-Null # this is way too noisy for some reason
    }

    $vaults = Get-AzDataProtectionBackupVault -ResourceGroupName $ResourceGroupName #-Verbose 

    foreach ($vault in $vaults) {
        Write-Host "Data Protection Vault: $($vault.name)"
        $backupInstances = Get-AzDataProtectionBackupInstance -ResourceGroupName $ResourceGroupName -VaultName $vault.Name
        foreach ($bi in $backupInstances) {
            Write-Host "Removing Backup Instance: $($bi.name)"
            Remove-AzDataProtectionBackupInstance -ResourceGroupName $ResourceGroupName -VaultName $vault.Name -Name $bi.Name 
        }
    
        $backupPolicies = Get-AzDataProtectionBackupPolicy -ResourceGroupName $ResourceGroupName -VaultName $vault.Name 
        foreach ($bp in $backupPolicies) {
            Write-Host "Removing backup policy: $($bp.name)"
            Remove-AzDataProtectionBackupPolicy -ResourceGroupName $ResourceGroupName -VaultName $vault.name -Name $bp.Name   
        }
    }
}


$eventHubs = Get-AzEventHubNamespace -ResourceGroupName $ResourceGroupName -Verbose  #-Name $VaultName 

#first look at the primary namespaces and break pairing
foreach ($eventHub in $eventHubs) {
    $drConfig = Get-AzEventHubGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name -Verbose
    $drConfig
    if ($drConfig) {
        if ($drConfig.Role.ToString() -eq "Primary") {
            #there is a partner namespace, break the pair before removing
            Write-Host "EventHubs Break Pairing... (primary)"
            Set-AzEventHubGeoDRConfigurationBreakPair -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name -Name $drConfig.Name
        }
    }
}

#now that pairing is removed we can remove primary and secondary configs
foreach ($eventHub in $eventHubs) {
    Write-Host "EventHubs remove DR config..."
    $drConfig = Get-AzEventHubGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name -Verbose

    #### DEBUG THIS: I think this can only be done on primary?  So need to handle the error - once config is removed resource can be deleted by job
    Remove-AzEventHubGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $eventHub.Name $drConfig.Name -Verbose
}


#remove DR for servicebuses - this is not bug free bug seems to work (one of the cmdlets returns NotFound)
$serviceBusNamespaces = Get-AzServiceBusNamespace -ResourceGroupName $ResourceGroupName -Verbose

#first look at the primary namespaces and break pairing
foreach ($s in $serviceBusNamespaces) {
    Write-Host "ServiceBus Break pairing..."
    $drConfig = Get-AzServiceBusGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $s.Name
    $drConfig
    if ($drConfig) {
        if ($drConfig.Role.ToString() -eq "Primary") {
            #there is a partner namespace, break the pair before removing
            Write-Host "ServiceBus Break pairing... (primary)"
            Set-AzServiceBusGeoDRConfigurationBreakPair -ResourceGroupName $ResourceGroupName -Namespace $s.Name -Name $drConfig.Name
        }
    }
}

#now that pairing is removed we can remove primary and secondary configs
foreach ($s in $serviceBusNamespaces) {
    $drConfig = Get-AzServiceBusGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $s.Name
    if ($drConfig) {
        Write-Host "Service Bus remove DR config..."
        Remove-AzServiceBusGeoDRConfiguration -ResourceGroupName $ResourceGroupName -Namespace $s.Name -Name $drConfig.Name -Verbose
    }
    # ??? Remove-AzureRmServiceBusNamespace -ResourceGroupName $ResourceGroupName -Name $s.Name -Verbose
}

foreach ($s in $serviceBusNamespaces) {
    # set ErrorAction on this since it throws if there is no config (unlike the other cmdlets)
    $migrationConfig = Get-AzServiceBusMigration -ResourceGroupName $ResourceGroupName -Name $s.Name -ErrorAction SilentlyContinue
    if ($migrationConfig) {
        Write-Host "Service Bus remove migration..."
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

# web apps that have a serviceAssociationLink can be deleted even if the link exists and the vnet will be bricked 
# (cannot be delete and the serviceAssociation link cannot be removed)
# a funky traversal of 3 resources are needed to discover and remove the link (PUT/GET/DELETE are not symmetrical)
$webapps = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Verbose
foreach ($w in $webapps) {
    Write-Host "WebApp: $($w.Name)"
    $slots = Get-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $w.Name -Verbose
    foreach ($s in $slots) {
        $slotName = $($s.Name).Split('/')[1]
        # assumption is that there can only be one vnetConfig but it returns an array so maybe not
        $r = Invoke-AzRestMethod -Method "GET" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/slots/$slotName/virtualNetworkConnections?api-version=2020-10-01"
        Write-Host "Slot: $slotName / $($r.StatusCode)"
        if ($r.StatusCode -eq '200') {
            # The URI for remove is not the same as the GET URI
            $r | Out-String
            Invoke-AzRestMethod -Method "DELETE" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/slots/$slotName/networkConfig/virtualNetwork?api-version=2020-10-01" -Verbose
        }
    }
    # now remove the config on the webapp itself
    $r = Invoke-AzRestMethod -Method "GET" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/virtualNetworkConnections?api-version=2020-10-01"
    Write-Host "Prod Slot: $($r.StatusCode)"
    if ($r.StatusCode -eq '200') {
        # The URI for remove is not the same as the GET URI
        $r | Out-String
        Invoke-AzRestMethod -Method "DELETE" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/networkConfig/virtualNetwork?api-version=2020-10-01" -Verbose
    }
}


#removing the link is async and takes a while, so remove the RG will likely still fail unless we want to wait - status takes a while to populate so polling will be hard
$redisCaches = Get-AzRedisCache -ResourceGroupName $ResourceGroupName -Verbose

foreach ($r in $redisCaches) {
    Write-Host "Redis..."
    $link = Get-AzRedisCacheLink -Name $r.Name
    if ($link) {
        Write-Host "Remove Redis Link..."
        $link | Remove-AzRedisCacheLink -Verbose
    }
}

# WebApps can have subnet delegation
# this appears to be duplicated above...
# $webapps = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Verbose
# foreach($w in $webapps){
#     Write-Host "WebApp: $($w.Name)"
#     $slots = Get-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $w.Name -Verbose
#     foreach($s in $slots){
#         $slotName = $($s.Name).Split('/')[1]
#         # assumption is that there can only be one vnetConfig but it returns an array so maybe not
#         $r = Invoke-AzRestMethod -Method "GET" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/slots/$slotName/virtualNetworkConnections?api-version=2020-10-01"
#         Write-Host "Slot: $slotName / $($r.StatusCode)"
#         if($r.StatusCode -eq '200'){
#             # The URI for remove is not the same as the GET URI
#             $r | Out-String
#             Invoke-AzRestMethod -Method "DELETE" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/slots/$slotName/networkConfig/virtualNetwork?api-version=2020-10-01" -Verbose
#         }
#     }
#     # now remove the config on the webapp itself
#     $r = Invoke-AzRestMethod -Method "GET" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/virtualNetworkConnections?api-version=2020-10-01"
#     Write-Host "Prod Slot: $($r.StatusCode)"
#     if($r.StatusCode -eq '200'){
#         # The URI for remove is not the same as the GET URI
#         $r | Out-String
#         Invoke-AzRestMethod -Method "DELETE" -Path "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$($w.name)/networkConfig/virtualNetwork?api-version=2020-10-01" -Verbose
#     }
# }

#ACI create a subnet delegation that must be removed before the vnet can be deleted
$vnets = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Verbose

foreach ($vnet in $vnets) {
    Write-Host "Vnet Delegation..."
    foreach ($subnet in $vnets.Subnets) {
        $delegations = Get-AzDelegation -Subnet $subnet -Verbose
        foreach ($d in $delegations) {
            Write-Output "Removing VNet Delegation: $($d.name)"
            Remove-AzDelegation -Name $d.Name -Subnet $subnet -Verbose
        }
    }
}

# Virtual Hubs can have ipConfigurations that take a few minutes to delete - there appear to be no cmdlets or CLI to invoke these apis
$vHubs = Get-AzVirtualHub -ResourceGroupName $ResourceGroupName -Verbose
foreach ($h in $vHubs) {
    # see if there is are any ipConfigurations on the hub
    Write-Host "Checking for ipConfigurations in vhub: $($h.name)"
    $r = Invoke-AzRestMethod -Method "GET" -path "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Network/virtualHubs/$($h.name)/ipConfigurations?api-version=2020-11-01"
    $r | Out-String
    $ipConfigs = $($r.Content | ConvertFrom-Json -Depth 50).Value
    $ipConfigs | Out-String
    foreach ($config in $ipConfigs) {
        Write-Host "Attempting to remove: $($config.name)"
        $r = Invoke-AzRestMethod -Method DELETE -Path "$($config.id)?api-version=2020-11-01"
        $r | Out-String
        if ($r.StatusCode -like "20*") {
            do {
                Start-Sleep 60 -Verbose
                $r = Invoke-AzRestMethod -Method GET -Path "$($config.id)?api-version=2020-11-01"
                $r | Out-String
                # wait until the delete is finished and GET returns 404
            } until ($r.StatusCode -eq "404")
        }
    }
}

# Private Link Endpoint Connections
$privateLinks = Get-AzPrivateLinkService -ResourceGroupName $ResourceGroupName
foreach ($pl in $privateLinks) {
    Write-Host "Checking Private Links for endpoint connections..."
    $connections = Get-AzPrivateEndpointConnection -ResourceGroupName $ResourceGroupName -ServiceName $pl.Name
    foreach ($c in $connections) {
        Write-Host "Removing PrivateLink Endpoint Connection: $($c.name)"
        Remove-AzPrivateEndpointConnection -ResourceGroupName $ResourceGroupName -ServiceName $pl.Name -Name $c.Name -Force
    }
}


# TODO - logAnalytics now has soft delete by default, this apparently can be overridden but doesn't seem to work in portal in FF


#finally...
Remove-AzResourceGroup -Force -Verbose -Name $ResourceGroupName

