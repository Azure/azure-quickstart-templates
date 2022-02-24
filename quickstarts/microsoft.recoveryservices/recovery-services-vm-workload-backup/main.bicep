@description('Name of the Vault')
param vaultName string = 'SqlBackupDemoVault'

@description('Resource group of Compute VM containing the workload')
param vmResourceGroup string

@description('Name of the Compute VM containing the workload')
param vmName string = 'sqlvmbackupdemo'

@description('Backup Policy Name')
param policyName string

@description('Name of database server instance')
param databaseInstanceName string

@description('Name of protectable data source i.e. Database Name')
param databaseName string

@description('Conditional parameter for New or Existing Vault')
param isNewVault bool = false

@description('Conditional parameter for New or Existing Backup Policy')
param isNewPolicy bool = false

@description('Workload type which is installed in VM and Pre-Registration Steps are performed')
@allowed([
  'SQLDataBase'
])
param workloadType string = 'SQLDataBase'

@description('Protected Item (Database) type')
@allowed([
  'AzureVmWorkloadSQLDatabaseProtectedItem'
])
param protectedItemType string = 'AzureVmWorkloadSQLDatabaseProtectedItem'

@description('Location for all resources.')
param location string = resourceGroup().location

var skuName = 'RS0'
var skuTier = 'Standard'
var backupFabric = 'Azure'
var containerType = 'VMAppContainer'
var backupManagementType = 'AzureWorkload'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2020-10-01' = if (isNewVault) {
  name: vaultName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {}
}

resource protectionContainer 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2021-03-01' = {
  name: '${vaultName}/${backupFabric}/${containerType};compute;${vmResourceGroup};${vmName}'
  properties: {
    containerType: containerType
    backupManagementType: backupManagementType
    workloadType: workloadType
    friendlyName: vmName
    sourceResourceId: resourceId(vmResourceGroup, 'Microsoft.Compute/virtualMachines', vmName)
  }
  dependsOn: [
    recoveryServicesVault
    backupPolicy
  ]
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-03-01' = if (isNewPolicy) {
  parent: recoveryServicesVault
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

resource protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-03-01' = {
  parent: protectionContainer
  name: '${workloadType};${databaseInstanceName};${databaseName}'
  properties: {
    backupManagementType: backupManagementType
    workloadType: workloadType
    protectedItemType: protectedItemType
    friendlyName: databaseName
    policyId: backupPolicy.id
  }
}
