param armProviderNamespace string = 'Microsoft.RecoveryServices'
param vaultName string = 'utk-ccy-vlt'
param backupManagementType string = 'AzureWorkload'
param workloadType string = 'SAPAseDatabase'
param policyName string = 'DailyPolicy-m85s4oxj'
param fabricName string = 'Azure'
param protectionContainers array = [
  'vmappcontainer;compute;utk-ccy-pe;utk-vm-asepe'
]
param protectedItems array = [
  'sapasedatabase;ab4;asetestdb3'
]
param protectedItemTypes array = [
  'AzureVmWorkloadAnyDatabase'
]
param vmName string = 'utk-vm-asepe'
param vmResourceGroup string = 'utk-ccy-pe'

@description('Conditional parameter for New or Existing Vault')
param isNewVault bool = false

@description('Conditional parameter for New or Existing Backup Policy')
param isNewPolicy bool = false

@description('Location for all resources.')
param location string = resourceGroup().location

var skuName = 'RS0'
var skuTier = 'Standard'
var backupFabric = 'Azure'
var containerType = 'VMAppContainer'

resource vault 'Microsoft.RecoveryServices/vaults@2020-10-01' = if (isNewVault) {
  name: vaultName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {}
}

resource vaultName_backupFabric_containerType_compute_vmResourceGroup_vm 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2021-03-01' = {
  name: '${vaultName}/${backupFabric}/${containerType};compute;${vmResourceGroup};${vmName}'
  properties: {
    containerType: containerType
    backupManagementType: backupManagementType
    workloadType: workloadType
    friendlyName: vmName
    sourceResourceId: resourceId(vmResourceGroup, 'Microsoft.Compute/virtualMachines', vmName)
  }
  dependsOn: [
    vaultName_policy
    vault
  ]
}

resource vaultName_policy 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-03-01' = if (isNewPolicy) {
  parent: vault
  name: policyName
  properties: {
    backupManagementType: backupManagementType
    workloadType: workloadType
    settings: {
      timeZone: 'UTC'
      issqlcompression: false
      isCompression: false
    }
    subProtectionPolicy: [
      {
        policyType: 'Full'
        schedulePolicy: {
          schedulePolicyType: 'SimpleSchedulePolicy'
          scheduleRunFrequency: 'Daily'
          scheduleRunTimes: [
            '2019-03-24T16:00:00Z'
          ]
          scheduleWeeklyFrequency: 0
        }
        retentionPolicy: {
          retentionPolicyType: 'LongTermRetentionPolicy'
          dailySchedule: {
            retentionTimes: [
              '2019-03-24T16:00:00Z'
            ]
            retentionDuration: {
              count: 30
              durationType: 'Days'
            }
          }
        }
      }
      {
        policyType: 'Log'
        schedulePolicy: {
          schedulePolicyType: 'LogSchedulePolicy'
          scheduleFrequencyInMins: 60
        }
        retentionPolicy: {
          retentionPolicyType: 'SimpleRetentionPolicy'
          retentionDuration: {
            count: 30
            durationType: 'Days'
          }
        }
      }
    ]
  }
}

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
