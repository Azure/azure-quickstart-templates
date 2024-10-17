@description('Location for all resources.')
param location string = resourceGroup().location

@description('Recovery service vault name')
param recoveryServiceVaultName string
@description('Recovery service vault backup policy name')
param backupPolicyName string = 'DailyPolicy-${uniqueString(resourceGroup().id)}'

param storageAccountId string
param fileShareName string

@description('Backup policy time zone')
param timeZone string = 'Central Standard Time'


resource recoveryServiceVault 'Microsoft.RecoveryServices/vaults@2024-04-30-preview' = {
  name: recoveryServiceVaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    redundancySettings: {
      crossRegionRestore: 'Disabled'
      standardTierStorageRedundancy: 'GeoRedundant'
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource backupPolicies 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-04-30-preview' = {
  parent: recoveryServiceVault
  location: location
  name: backupPolicyName
  properties: {
    backupManagementType: 'AzureStorage'
    workLoadType: 'AzureFileShare'
    protectedItemsCount: 0
    timeZone: timeZone
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleWeeklyFrequency: 0
      scheduleRunTimes: [
        '05:30'
      ]
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '05:30'
        ]
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
    }
  }
}

resource protectionContainers 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2024-04-30-preview' = {
  location: location
  name: format('{0}/{1}/storagecontainer;Storage;{2};{3}', recoveryServiceVault.name, 'Azure', split(storageAccountId, '/')[4], split(storageAccountId, '/')[8])
  properties: {
    backupManagementType: 'AzureStorage'
    containerType: 'StorageContainer'
    sourceResourceId: storageAccountId
  }
}

resource protectedItems 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2024-04-30-preview' = {
  parent: protectionContainers
  location: location
  name: 'AzureFileShare;${fileShareName}'
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    sourceResourceId: storageAccountId
    policyId: backupPolicies.id
  }
}
