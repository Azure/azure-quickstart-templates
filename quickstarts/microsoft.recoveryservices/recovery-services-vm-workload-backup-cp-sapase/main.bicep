param armProviderNamespace string = 'Microsoft.RecoveryServices'
param vaultName string = 'utk-ccy-vlt'
param vaultRG string = 'utk-ccy-pe'
param vaultSubID string = '14d16a2a-56f6-4c75-b091-084df9640297'
param backupManagementType string = 'AzureWorkload'
param workloadType string = 'SAPAseDatabase'
param policyName string = 'DailyPolicy-m85s4oxj'
param fabricName string = 'Azure'
param protectionContainers array = [
  'vmappcontainer;compute;utk-ccy-pe;utk-vm-asepe'
]
param protectedItems array = [
  'sapasedatabase;ab4;asetestdb2'
]
param protectedItemTypes array = [
  'AzureVmWorkloadAnyDatabase'
]

resource vaultName_fabricName_protectionContainers_protectedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2016-06-01' = [
  for (item, i) in protectedItems: {
    name: '${vaultName}/${fabricName}/${protectionContainers[i]}/${item}'
    properties: {
      backupManagementType: backupManagementType
      workloadType: workloadType
      policyId: resourceId('${armProviderNamespace}/vaults/backupPolicies', vaultName, policyName)
      protectedItemType: protectedItemTypes[i]
    }
  }
]
