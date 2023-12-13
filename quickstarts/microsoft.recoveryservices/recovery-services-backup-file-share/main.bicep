@description('Name of the existing Resource Group in which the existing Storage Account is present.')
param existingResourceGroupName string = resourceGroup().name

@description('Name of the existing Storage Account in which the existing File Share to be protected is present.')
param existingStorageAccountName string

@description('Name of the existing File Share to be protected.')
param existingFileShareName string

@description('Location of the existing Storage Account containing the existing File Share to be protected. New Recovery Services Vault will be created in this location. (Ignore if using existing Recovery Services Vault).')
param location string = resourceGroup().location

@description('Set to true if a new Recovery Services Vault is to be created; set to false otherwise.')
param isNewVault bool = true

@description('Set to true if a new Backup Policy is to be created for the Recovery Services Vault; set to false otherwise.')
param isNewPolicy bool = true

@description('Set to true if the existing Storage Account has to be registered to the Recovery Services Vault; set to false otherwise.')
param registerStorageAccount bool = true

@description('Name of the Recovery Services Vault. (Should have the same location as the Storage Account containing the File Share to be protected in case of an existing Recovery Services Vault).')
param vaultName string = 'RSVault1'

@description('Name of the Backup Policy.')
param policyName string = 'DailyBackupPolicy1'

@description('Time of day when backup should be triggered in 24 hour HH:MM format, where MM must be 00 or 30. (Ignore if using existing Backup Policy).')
param scheduleRunTime string = '05:30'

@description('Any valid timezone, for example: UTC, Pacific Standard Time. Refer: https://msdn.microsoft.com/en-us/library/gg154758.aspx (Ignore if using existing Backup Policy).')
param timeZone string = 'UTC'

@description('Number of days for which the daily backup is to be retained. (Ignore if using existing Backup Policy).')
param dailyRetentionDurationCount int = 30

@description('Array of days on which backup is to be performed for Weekly Retention. (Ignore if using existing Backup Policy).')
param daysOfTheWeek array = [
  'Sunday'
  'Tuesday'
  'Thursday'
]

@description('Number of weeks for which the weekly backup is to be retained. (Ignore if using existing Backup Policy).')
param weeklyRetentionDurationCount int = 12

@description('Number of months for which the monthly backup is to be retained. Backup will be performed on the 1st day of every month. (Ignore if using existing Backup Policy).')
param monthlyRetentionDurationCount int = 60

@description('Array of months on which backup is to be performed for Yearly Retention. Backup will be performed on the 1st day of each month of year provided. (Ignore if using existing Backup Policy).')
param monthsOfYear array = [
  'January'
  'May'
  'September'
]

@description('Number of years for which the yearly backup is to be retained. (Ignore if using existing Backup Policy).')
param yearlyRetentionDurationCount int = 10

var backupFabric = 'Azure'
var backupManagementType = 'AzureStorage'
var scheduleRunTimes = [
  '2020-01-01T${scheduleRunTime}:00Z'
]

resource vault 'Microsoft.RecoveryServices/vaults@2021-12-01' = if (isNewVault) {
  name: vaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-12-01' = if (isNewPolicy) {
  parent: vault
  name: policyName
  properties: {
    backupManagementType: backupManagementType
    schedulePolicy: {
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: scheduleRunTimes
      schedulePolicyType: 'SimpleSchedulePolicy'
    }
    retentionPolicy: {
      dailySchedule: {
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: dailyRetentionDurationCount
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: daysOfTheWeek
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: weeklyRetentionDurationCount
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Daily'
        retentionScheduleDaily: {
          daysOfTheMonth: [
            {
              date: 1
              isLast: false
            }
          ]
        }
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: monthlyRetentionDurationCount
          durationType: 'Months'
        }
      }
      yearlySchedule: {
        retentionScheduleFormatType: 'Daily'
        monthsOfYear: monthsOfYear
        retentionScheduleDaily: {
          daysOfTheMonth: [
            {
              date: 1
              isLast: false
            }
          ]
        }
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: yearlyRetentionDurationCount
          durationType: 'Years'
        }
      }
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
    timeZone: timeZone
    workLoadType: 'AzureFileShare'
  }
}

resource protectionContainer 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2021-12-01' = if (registerStorageAccount) {
  name: '${vaultName}/${backupFabric}/storagecontainer;Storage;${existingResourceGroupName};${existingStorageAccountName}'
  properties: {
    backupManagementType: backupManagementType
    containerType: 'StorageContainer'
    sourceResourceId: resourceId(existingResourceGroupName, 'Microsoft.Storage/storageAccounts', existingStorageAccountName)
  }
  dependsOn: [
    vault
  ]
}

resource protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-12-01' = {
  parent: protectionContainer
  name: 'AzureFileShare;${existingFileShareName}'
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    sourceResourceId: resourceId(existingResourceGroupName, 'Microsoft.Storage/storageAccounts', existingStorageAccountName)
    policyId: backupPolicy.id
    isInlineInquiry: true
  }
  dependsOn: [
    vault
  ]
}
