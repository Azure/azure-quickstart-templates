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
$OMSWorkspaceName = Get-AutomationVariable -Name 'OMSWorkspaceName'
$OMSResourceGroupName = Get-AutomationVariable -Name 'OMSResourceGroupName'

$vaults = Find-AzureRmResource `
                               -ResourceType microsoft.recoveryservices/vaults

foreach ($vault in $vaults)
{
    $vaultsettings = Get-AzureRmRecoveryServicesVault `
                    -Name $vault.name -ResourceGroupName $vault.resourcegroupname
                

# Setting vault context

$location = $vault.Location
Set-AzureRmSiteRecoveryVaultSettings `
                                     -ARSVault $vaultsettings
                                      
$con = Get-AzureRmSiteRecoveryProtectionContainer

if ([string]::IsNullOrEmpty($con) -eq $true)

    {
        Write-Output "ASR Recovery Vault isn't completely configured yet. No data to ingest from the specific Recovery Vault at this point"
    }
else {

$DRServer = Get-AzureRmSiteRecoveryServer
$heartbeat = ([datetime]$DRServer.LastHeartbeat).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss')
	$Table = @()
foreach ($c in $con) {
    $protectionEntity = Get-AzureRmSiteRecoveryProtectionEntity -ProtectionContainer $c

    if ($protectionentity.ReplicationProvider -eq "InMageAzureV2") {
        foreach ($entity in $protectionEntity) {
            $sx = New-Object PSObject -Property @{
            VMName = $entity.FriendlyName;
            ResourceGroup = $ResourceGroup;
            RecoveryVault = $vault.Name;
            ProtectionState = $entity.ProtectionStateDescription;
            ReplicationHealth = $entity.ReplicationHealth;
            ReplicationProvider = $entity.ReplicationProvider;
            ActiveLocation = $entity.ActiveLocation;
            TestFailoverStateDescription = $entity.TestFailoverDescription
	    }
	    $table = $table += $sx
 
      $jsonTable = ConvertTo-Json -InputObject $table
	  } 
	$jsonTable 
    $logType = "ASRDiscovery"
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable -logType $logType
 }
 else {
	foreach($entity in $protectionEntity) { 
	    $sx = New-Object PSObject -Property @{
	        ResourceGroup = $ResourceGroup;
            RecoveryVault = $vault.Name;      
            VMName = $entity.FriendlyName;
	        ProtectionStatus = $entity.ProtectionStatus; 
	        ReplicationProvider = $entity.ReplicationProvider;
	        ActiveLocation = $entity.ActiveLocation;
            ReplicationHealth = $entity.ReplicationHealth;
            Disks = $entity.Disks.name;
            TestFailoverStateDescription = $entity.TestFailoverStateDescription;
            ProtectionContainerId = $entity.ProtectionContainerId;
            SiteRecoveryServerLastHeartbeat = $heartbeat;
            SiteRecoveyServerConnectionStatus = $drserver.Connected;
            SiteRecoveryServerProviderVersion = $drserver.ProviderVersion;
            SiteRecoveryServerServerVersion = $drserver.ServerVersion;
            SiteRecoveryServer = $DRServer.FriendlyName             
	    }
	    $table = $table += $sx
 
      $jsonTable = ConvertTo-Json -InputObject $table
	   }
    $jsontable
    $logType = "ASRDiscovery"
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable -logType $logType
        }
     }
   }

$Table2 = @()
    foreach ($c in $con) {
    $recoveryVm = Get-AzureRmSiteRecoveryVM -ProtectionContainer $c | where-object {$_.ProtectionStatus -eq "Protected"}
	foreach($rVm in $recoveryVm) {        
       if ($rvm.ReplicationProvider -eq "InMageAzureV2")
       {
            $vnetInfo = "None"
            $vnetRgName = "None"
            $storageInfo = "None"
            $storageRgName = "None"
            $storageName = "None"
            
         $sx2 = New-Object PSObject -Property @{
	        VMName = $rVm.FriendlyName;
            vNetName = $vnetInfo;
            vNetResourceGroup = $vnetRgName;
            StorageResourceGroup = $storageRgName;
            StorageAccount = $storageName;
            ReplicationHealth = $rVm.ReplicationHealth;
            RecoveryAzureVMSize = $rVm.RecoveryAzureVMSize;
            RecoveryAzureVMName = $rVm.RecoveryAzureVMName;
            ActiveLocation = $rVm.ActiveLocation;
            TestFailoverStateDescription = $rVm.TestFailoverStateDescription;
            ReplicationProvider = $rVm.ReplicationProvider;
            ProtectionStatus = $rVm.ProtectionStatus             
	            }      
	    $table2 = $table2 += $sx2 
 
      $jsonTable2 = ConvertTo-Json -InputObject $table2
      
     $jsonTable2
     $logType2 = "ASRProtection"      
     Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable2 -logType $logType2
      }         
        else {
        if($rVm.SelectedRecoveryAzureNetworkId -ne $null)
        {
        $vnetInfo = $rVm.SelectedRecoveryAzureNetworkId.split("/")
        $vnetRgName = $vnetInfo[4]
        $vnetName = $vnetInfo[8]
        $storageInfo = $rVm.RecoveryAzureStorageAccount.split("/")
        $storageRgName = $storageInfo[4]
        $storageName = $storageInfo[8]

	    $sx2 = New-Object PSObject -Property @{
	        VMName = $rVm.FriendlyName;
            vNetName = $vnetName;
            vNetResourceGroup = $vnetRgName;
            StorageResourceGroup = $storageRgName;
            StorageAccount = $storageName;
            ReplicationHealth = $rVm.ReplicationHealth;
            RecoveryAzureVMSize = $rVm.RecoveryAzureVMSize;
            RecoveryAzureVMName = $rVm.RecoveryAzureVMName;
            ActiveLocation = $rVm.ActiveLocation;
            TestFailoverStateDescription = $rVm.TestFailoverStateDescription;
            ReplicationProvider = $rVm.ReplicationProvider;
            ProtectionStatus = $rVm.ProtectionStatus             
	            }
	    $table2 = $table2 += $sx2
 
      $jsonTable2 = ConvertTo-Json -InputObject $table2
	        
	$jsonTable2
    $logType2 = "ASRProtection"
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable2 -logType $logType2
      }
       else {
        $vnetInfo = "None"
        $vnetRgName = "None"
        $sx2 = New-Object PSObject -Property @{
	        VMName = $rVm.FriendlyName;
            vNetName = $vnetInfo;
            vNetResourceGroup = $vnetRgName;
            StorageResourceGroup = $storageRgName;
            StorageAccount = $storageName;
            ReplicationHealth = $rVm.ReplicationHealth;
            RecoveryAzureVMSize = $rVm.RecoveryAzureVMSize;
            RecoveryAzureVMName = $rVm.RecoveryAzureVMName;
            ActiveLocation = $rVm.ActiveLocation;
            TestFailoverStateDescription = $rVm.TestFailoverStateDescription;
            ReplicationProvider = $rVm.ReplicationProvider;
            ProtectionStatus = $rVm.ProtectionStatus             
	            }
	    $table2 = $table2 += $sx2
 
      $jsonTable2 = ConvertTo-Json -InputObject $table2
	        
	$jsonTable2
    $logType2 = "ASRProtection"
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable2 -logType $logType2
     }
    }
   }
 }          

# Fetching information from ASR Jobs

$jobs = Get-AzureRmSiteRecoveryJob

# Format Jobs into a table.
$Table3 = @()
	foreach($job in $jobs) { 
    $starttime = ([datetime]$job.StartTime).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss')
    if ($job.EndTime -eq $null)
    { "Ignore"}
    else {
    $endtime = ([datetime]$job.EndTime).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss')
    }
	    $sx3 = New-Object PSObject -Property @{
	        JobName = $job.DisplayName;
            JobType = $job.JobType;
            State = $job.State;
            StateDescription = $job.StateDescription;
            TargetObjectName = $job.TargetObjectName;
            TargetObjectType = $job.TargetObjectType;
            AllowedActions = $job.AllowedActions;
            Errors = $job.Errors;
            Tasks = $job.Tasks;
            StartTime = $starttime;
            EndTime = $endtime;
            ID = $job.ID;             
	    }
	    $table3 = $table3 += $sx3
 
      $jsonTable3 = ConvertTo-Json -InputObject $table3
	}
	$jsonTable3
    $logType3 = "ASRJobHistory"
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable3 -logType $logType3

# Capacity planning

$vmSize = Get-AzureRmVMSize -Location $location
$currentUsage = Get-AzureRmVMUsage -Location $location
$currentStorage = Get-AzureRmStorageUsage 
$allvms = Get-AzureRmVM | measure
                                     
$Table4  = @()
    foreach ($c in $con) {
        $recoveryVmSize = Get-AzureRmSiteRecoveryVM -ProtectionContainer $c
            foreach ($vmSize in $recoveryVmSize) { 
                $sizeobj = Get-AzureRmVMSize -location $location | where-object {$_.Name -eq $vmSize.RecoveryAzureVmSize }
                $usage = Get-AzureRmVMUsage -Location $location 
         $sx4  = New-Object PSObject -Property @{ 
                         'NumberOfCores'        = $sizeobj.NumberOfCores;
                         'VMName'             = $vmsize.FriendlyName;
                         'VMSize'       = $vmsize.RecoveryAzureVMSize;
                         'AzureSubscriptionVMCoresInUse' = $usage[1].CurrentValue;
                         'AzureSubscriptionVMCoresTotalLimit' = $usage[1].Limit;
                         'AzureSubscriptionVMsInUse' = $usage[2].CurrentValue;
                         'AzureSubscriptionVMsTotalLimit' = $usage[2].Limit;
                         'AzureSubscriptionStandard_DScoresTotalLimit' = $usage[4].Limit;
                         'AzureSubscriptionStandard_DcoresTotalLimit' = $usage[5].Limit;
                         'AzureSubscriptionStandard_AcoresTotalLimit' = $usage[6].Limit;
                         'RecoveryVaultRegion' = $location;
                         'CurrentVMsAcrossSubscription' = $allvms.Count;
                         'CurrentStorageAccountsAcrossSubscription' = $currentStorage.CurrentValue;
                         'StorageAccountLimit' = $currentStorage.Limit
                         }
           $table4 = $table4 += $sx4
         
          $jsonTable4 = ConvertTo-Json -InputObject $Table4
            }
        }
    $jsontable4
    $logType4 = "ASRCapacityPlanning"
    Send-OMSAPIIngestionData -customerId $OMSWorkspaceId -sharedKey $OMSWorkspaceKey -body $jsonTable4 -logType $logType4
}