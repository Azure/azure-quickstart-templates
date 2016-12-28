<#
.Synopsis
   Runbook for OMS ASR Log Ingestion
.DESCRIPTION
   This Runbook will ingest ASR related logs to OMS Log Analytics. Preview 0.9 will have limited support for VMware/Physical 2 Azure scenario. 
.AUTHOR
    Kristian Nese (Kristian.Nese@Microsoft.com) ECG OMS CAT
#>

"Logging in to Azure..."
$Conn = Get-AutomationConnection -Name AzureRunAsConnection 
 Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

"Selecting Azure subscription..."
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID -TenantId $Conn.tenantid 


$OMSWorkspaceId = Get-AutomationVariable -Name 'OMSWorkspaceId'
$OMSWorkspaceKey = Get-AutomationVariable -Name 'OMSWorkspaceKey'
$AzureSubscriptionId = Get-AutomationVariable -Name 'AzureSubscriptionId'

# Finding all ASR Recovery Vaults within the Azure subscription

$Vaults = Find-AzureRmResource `
                              -ResourceType Microsoft.RecoveryServices/vaults

Write-Output "Found the following vaults:" $Vaults.name

# Iterate through all Recovery Vaults and ingest data to OMS Log Analytics

foreach ($Vault in $Vaults)
{
    # Setting Vault context
    $VaultSettings = Get-AzureRmRecoveryServicesVault `
                                                     -Name $Vault.Name `
                                                     -ResourceGroupName $Vault.ResourceGroupName
    Write-Output $VaultSettings

    $Location = $Vault.Location

    Set-AzureRmSiteRecoveryVaultSettings `
                                        -ARSVault $VaultSettings
    # Ingesting ASRJobs into OMS

    $ASRLogs = @()
    $LogData = New-Object psobject -Property @{}

    $ASRJobs = Get-AzureRmSiteRecoveryJob `
                                         -StartTime (Get-Date).AddHours(((-1)))

    if ($ASRJobs -eq $null)
    {
        Write-output "No new logs to collect"
    } 
    else 
    {
        if ($ASRJobs.EndTime -eq $null) 
        {
            foreach ($job in $ASRJobs) 
            {
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name LogType -Value ASRJob
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name JobType -Value $job.JobType
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name State -Value $job.State
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name StateDescription -Value $job.StateDescription                
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name StartTime -Value $job.StartTime.ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ss')
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name TargetObjectType -Value $job.TargetObjectType
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name TargetObjectName -Value $job.TargetObjectName
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name ID -Value $job.ID
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name SubscriptionId -Value $azuresubscriptionid
            }
        }
        else 
        {
            foreach ($job in $ASRJobs) 
            {
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name LogType -Value ASRJob
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name JobType -Value $job.JobType
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name State -Value $job.State
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name StateDescription -Value $job.StateDescription
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name StartTime -Value $job.StartTime.ToUniversalTime().ToString('yyyy-MM-ddtHH:mm:ss')                
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name EndTime -Value $job.EndTime.ToUniversalTime().ToString('yyyy-mm-ddtHH:mm:ss')
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name TargetObjectType -Value $job.TargetObjectType
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name TargetObjectName -Value $job.TargetObjectName
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name ID -Value $job.ID
                Add-Member -InputObject $LogData -MemberType NoteProperty -Name SubscriptionId -Value $azuresubscriptionid
            }
        }
    $ASRLogs += $LogData
    Write-output $ASRLogs

    $ASRLogsJson = ConvertTo-Json -InputObject $ASRLogs
    $LogType = "RecoveryServices"

    Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $ASRLogsJson -logType $LogType

    }

    # Get all Protection Containers for the Recovery Vault

    $Containers = Get-AzureRmSiteRecoveryProtectionContainer

    If ([string]::IsNullOrEmpty($Containers) -eq $true)
    {
        Write-Output "ASR Recovery Vault isn't completely configured yet. No data to ingest from the specific Recovery Vault at this point"
    }
    else
    {
        Write-Output $Containers.FriendlyName

        # Iterate through all Containers, discover protection entities and send data to OMS
        foreach ($Container in $Containers)
        {
            
            $VMSize = Get-AzureRmVMSize `
                                       -Location $Location

            $CurrentVMUsage = Get-AzureRmVMUsage `
                                       -Location $Location

            $CurrentStorageUsage = Get-AzureRmStorageUsage

            $AllVms = Get-AzureRmVm

            $DRServer = Get-AzureRmSiteRecoveryServer

            $RecoveryVms = Get-AzureRmSiteRecoveryVM `
                                       -ProtectionContainer $Container
            
            Write-Output $RecoveryVms.FriendlyName

            # Getting VM Details
            foreach ($RecoveryVm in $RecoveryVms)
            {
                $VMSize = Get-AzureRmVMSize `
                                           -Location $Location | Where-Object {$_.Name -eq $RecoveryVm.RecoveryAzureVMSize}
                
                # Detect VMs protected by InMageAzureV2 Replication Provider
                if ($RecoveryVm.ReplicationProvider -eq "InMageAzureV2")
                {
                    $vNetInfo = "None"
                    $vNetRgName = "None"
                    $StorageInfo = "None"
                    $StorageRgName = "None"
                    $StorageName = "None"
                    
                    Write-Output "Found the following VMware protected machines" $RecoveryVm.FriendlyName
                }
                # Detect VMs Protected using Hyper-V 2 Azure
                else
                {
                    # Detect VMs that are connected to storage and vNet in Azure
                    if($RecoveryVm.SelectedRecoveryAzureNetworkId -ne $null -and $RecoveryVm.RecoveryAzureStorageAccount -ne $null -and $RecoveryVm.ReplicationProvider -ne "HyperVReplica2012R2")
                    {
                        $vNetInfo = $RecoveryVm.SelectedRecoveryAzureNetworkId.split("/")
                        $vNetRgName = $vNetInfo[4]
                        $vNetName = $vNetInfo[8]
                        $StorageInfo = $RecoveryVm.RecoveryAzureStorageAccount.split("/")
                        $StorageRgName = $StorageInfo[4]
                        $StorageName = $StorageInfo[8]
                        
                        Write-Output "Found the following Hyper-V protected machines" $RecoveryVm.FriendlyName
                    }
                    # Detect VMs that are missing vNet connection in Azure
                    else
                    {
                        if ($RecoveryVm.RecoveryAzureStorageAccount -ne $null -and $RecoveryVm.SelectedRecoveryAzureNetworkId -eq $null -and $RecoveryVm.ReplicationProvider -ne "HyperVReplica2012R2")
                        {
                            $vNetRgName = "None"
                            $vNetName = "None"
                            $StorageInfo = $RecoveryVm.RecoveryAzureStorageAccount.split("/")
                            $StorageRgName = $StorageInfo[4]
                            $StorageName = $StorageInfo[8]

                            Write-Output "Found the following Hyper-V Protected machines missing vNet" $RecoveryVm.FriendlyName
                        }
                        # Ignoring On-Prem 2 On-Prem scenario for now
                        else
                        {
                            if ($RecoveryVm.ReplicationProvider -eq "HyperVReplica2012R2")
                            {
                                    $vNetRgName = "None"
                                    $vNetName = "None"
                                    $StorageRgName = "None"
                                    $StorageName = "None"

                                Write-Output "These VMs are ignored for OMS for now" $RecoveryVm.FriendlyName
                            }
                            # Fetching unprotected VMs with no Azure association
                            else
                            {
                                if($RecoveryVm.ReplicationProvider -eq $null)
                                {
                                    $vNetRgName = "None"
                                    $vNetName = "None"
                                    $StorageRgName = "None"
                                    $StorageName = "None"
                                    
                                    Write-Output "Found the following unprotected VMs" $RecoveryVm.FriendlyName
                                }
                            }
                        }
                    }
            #Constructing the data log for OMS Log Analytics

            $ASRVMs = @()
                $Data = New-Object psobject -Property @{
                    LogType = 'VM';
                    ASRResourceGroupName = $Vault.ResourceGroupName;
                    ASRVaultName = $vault.Name;
                    ASRVaultLocation = $Location;
                    VMName = $RecoveryVm.FriendlyName;
                    VMId = $RecoveryVm.ID.Split("/")[14];
                    ProtectionStatus = $RecoveryVm.ProtectionStatus;
                    ActiveLocation = $RecoveryVm.ActiveLocation;
                    ReplicationHealth = $RecoveryVm.ReplicationHealth;
                    TestFailoverDescription = $RecoveryVm.TestFailoverDescription;
                    AzureFailoverNetwork = $vNetName;
                    AzureStorageAccount = $StorageName;
                    AzurevNetResourceGroupName = $vNetRgName;
                    AzureStorageAccountResourceGroupName = $StorageRgName;
                    Disk = $RecoveryVm.Disks.Name;
                    SubscriptionId = $azuresubscriptionid;
                    ProviderHeartbeat = $DRServer[0].LastHeartbeat.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss');
                    SiteRecoveryServerConnectionStatus = $DRServer[0].Connected;
                    SiteRecoveryProviderVersion = $DRServer[0].ProviderVersion;
                    SiteRecoveryServerVersion = $DRServer[0].ServerVersion;
                    SiteRecoveryServer = $DRServer.FriendlyName;
                    NumberOfCores = $VMSize.NumberOfCores;
                    VMSize = $RecoveryVm.RecoveryAzureVMSize;
                    AzureVMCoresInUse = $CurrentVMUsage[1].CurrentValue;
                    AzureVMCoresTotalLimit = $CurrentVMUsage[1].Limit;
                    AzureVMsInUse = $CurrentVMUsage[2].CurrentValue;
                    AzureVMsTotalLimit = $CurrentVMUsage[2].Limit;
                    AzureVMsInSubscription = $AllVms.count;
                    AzureStorageAccountsInUse = $CurrentStorageUsage.CurrentValue;
                    AzureStorageAccountTotalLimit = $CurrentStorageUsage.Limit;
                    VMReplicationProvider = $RecoveryVm.ReplicationProvider
                    }
                
         $ASRVMs += $Data
         write-output $ASRVMs
         
         $ASRVMsJson = ConvertTo-Json -InputObject $ASRVMs

         $LogType = "RecoveryServices"

         Send-OMSAPIIngestionData -customerId $omsworkspaceId -sharedKey $omsworkspaceKey -body $ASRVMsJson -logType $LogType

            }
         }              
      }
   }   
}                                                                                           