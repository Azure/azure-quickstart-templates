@description('Name of the Vault')
param vaultName string = 'vault${uniqueString(resourceGroup().id)}'

@description('Change Vault Storage Type (not allowed if the vault has registered backups)')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param vaultStorageRedundancy string = 'GeoRedundant'

@description('Name of the Backup Policy')
param backupPolicyName string = 'policy${uniqueString(resourceGroup().id)}'

@description('Vault tier default backup retention duration in days')
@minValue(7)
@maxValue(3650)
param vaultTierDefaultRetentionInDays int = 30

@description('Vault tier weekly backup retention duration in weeks')
@minValue(4)
@maxValue(521)
param vaultTierWeeklyRetentionInWeeks int = 30

@description('Vault tier monthly backup retention duration in months')
@minValue(5)
@maxValue(116)
param vaultTierMonthlyRetentionInMonths int = 30

@description('Vault tier yearly backup retention duration in years')
@minValue(1)
@maxValue(10)
param vaultTierYearlyRetentionInYears int = 10

@description('Vault tier daily backup schedule time')
param vaultTierDailyBackupScheduleTime string = '06:00'

@description('Name of the Storage Account')
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}'

@description('List of the containers to be protected')
param containerList array = [
  'container1'
  'container2'
]

@description('Location for all resources')
param location string = resourceGroup().location

var roleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1'
)
var dataSourceType = 'Microsoft.Storage/storageAccounts/adlsBlobServices'
var resourceType = 'Microsoft.Storage/storageAccounts'
var vaultTierDefaultRetentionDuration = 'P${vaultTierDefaultRetentionInDays}D'
var vaultTierWeeklyRetentionDuration = 'P${vaultTierWeeklyRetentionInWeeks}W'
var vaultTierMonthlyRetentionDuration = 'P${vaultTierMonthlyRetentionInMonths}M'
var vaultTierYearlyRetentionDuration = 'P${vaultTierYearlyRetentionInYears}Y'
var repeatingTimeIntervals = 'R/2025-10-10T${vaultTierDailyBackupScheduleTime}:00+00:00/P1D'

resource vault 'Microsoft.DataProtection/backupVaults@2025-07-01' = {
  name: vaultName
  location: location
  identity: {
    type: 'systemAssigned'
  }
  properties: {
    storageSettings: [
      {
        datastoreType: 'VaultStore'
        type: vaultStorageRedundancy
      }
    ]
  }
}

resource backupPolicy 'Microsoft.DataProtection/backupVaults/backupPolicies@2025-07-01' = {
  parent: vault
  name: backupPolicyName
  properties: {
    policyRules: [
      {
        name: 'Yearly'
        objectType: 'AzureRetentionRule'
        isDefault: false
        lifecycles: [
          {
            deleteAfter: {
              duration: vaultTierYearlyRetentionDuration
              objectType: 'AbsoluteDeleteOption'
            }
            sourceDataStore: {
              dataStoreType: 'VaultStore'
              objectType: 'DataStoreInfoBase'
            }
            targetDataStoreCopySettings: []
          }
        ]
      }
      {
        name: 'Monthly'
        objectType: 'AzureRetentionRule'
        isDefault: false
        lifecycles: [
          {
            deleteAfter: {
              duration: vaultTierMonthlyRetentionDuration
              objectType: 'AbsoluteDeleteOption'
            }
            sourceDataStore: {
              dataStoreType: 'VaultStore'
              objectType: 'DataStoreInfoBase'
            }
            targetDataStoreCopySettings: []
          }
        ]
      }
      {
        name: 'Weekly'
        objectType: 'AzureRetentionRule'
        isDefault: false
        lifecycles: [
          {
            deleteAfter: {
              duration: vaultTierWeeklyRetentionDuration
              objectType: 'AbsoluteDeleteOption'
            }
            sourceDataStore: {
              dataStoreType: 'VaultStore'
              objectType: 'DataStoreInfoBase'
            }
            targetDataStoreCopySettings: []
          }
        ]
      }
      {
        name: 'Default'
        objectType: 'AzureRetentionRule'
        isDefault: true
        lifecycles: [
          {
            deleteAfter: {
              duration: vaultTierDefaultRetentionDuration
              objectType: 'AbsoluteDeleteOption'
            }
            sourceDataStore: {
              dataStoreType: 'VaultStore'
              objectType: 'DataStoreInfoBase'
            }
            targetDataStoreCopySettings: []
          }
        ]
      }
      {
        name: 'BackupDaily'
        objectType: 'AzureBackupRule'
        backupParameters: {
          backupType: 'Discrete'
          objectType: 'AzureBackupParams'
        }
        dataStore: {
          dataStoreType: 'VaultStore'
          objectType: 'DataStoreInfoBase'
        }
        trigger: {
          schedule: {
            timeZone: 'UTC'
            repeatingTimeIntervals: [
              repeatingTimeIntervals
            ]
          }
          taggingCriteria: [
            {
              isDefault: false
              taggingPriority: 10
              tagInfo: {
                id: 'Yearly_'
                tagName: 'Yearly'
              }
              criteria: [
                {
                  absoluteCriteria: [
                    'FirstOfYear'
                  ]
                  objectType: 'ScheduleBasedBackupCriteria'
                }
              ]
            }
            {
              isDefault: false
              taggingPriority: 15
              tagInfo: {
                id: 'Monthly_'
                tagName: 'Monthly'
              }
              criteria: [
                {
                  absoluteCriteria: [
                    'FirstOfMonth'
                  ]
                  objectType: 'ScheduleBasedBackupCriteria'
                }
              ]
            }
            {
              isDefault: false
              taggingPriority: 20
              tagInfo: {
                id: 'Weekly_'
                tagName: 'Weekly'
              }
              criteria: [
                {
                  absoluteCriteria: [
                    'FirstOfWeek'
                  ]
                  objectType: 'ScheduleBasedBackupCriteria'
                }
              ]
            }
            {
              isDefault: true
              taggingPriority: 99
              tagInfo: {
                id: 'Default_'
                tagName: 'Default'
              }
            }
          ]
          objectType: 'ScheduleBasedTriggerContext'
        }
      }
    ]
    datasourceTypes: [
      dataSourceType
    ]
    objectType: 'BackupPolicy'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    isHnsEnabled: true
  }
}

resource storageContainerList 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = [
  for item in containerList: {
    name: '${storageAccountName}/default/${item}'
    dependsOn: [
      storageAccount
    ]
  }
]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(vault.id, roleDefinitionId, storageAccount.id)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: reference(vault.id, '2021-01-01', 'Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource backupInstance 'Microsoft.DataProtection/backupVaults/backupInstances@2025-07-01' = {
  parent: vault
  name: storageAccountName
  properties: {
    objectType: 'BackupInstance'
    friendlyName: storageAccountName
    dataSourceInfo: {
      objectType: 'Datasource'
      resourceID: storageAccount.id
      resourceName: storageAccountName
      resourceType: resourceType
      resourceUri: storageAccount.id
      resourceLocation: location
      datasourceType: dataSourceType
    }
    dataSourceSetInfo: {
      objectType: 'DatasourceSet'
      resourceID: storageAccount.id
      resourceName: storageAccountName
      resourceType: resourceType
      resourceUri: storageAccount.id
      resourceLocation: location
      datasourceType: dataSourceType
    }
    policyInfo: {
      policyId: backupPolicy.id
      name: backupPolicyName
      policyParameters: {
        backupDatasourceParametersList: [
          {
            objectType: 'BlobBackupDatasourceParameters'
            containersList: containerList
          }
        ]
      }
    }
  }
  dependsOn: [
    roleAssignment
    storageContainerList
  ]
}
