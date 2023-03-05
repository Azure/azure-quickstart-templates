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

@description('Retention duration in days')
@minValue(1)
@maxValue(35)
param retentionDays int = 30

@description('Name of the Disk')
param diskName string = 'disk${uniqueString(resourceGroup().id)}'

@description('Location for all resources')
param location string = resourceGroup().location

var roleDefinitionIdForDisk = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3e5e47e6-65f7-47ef-90b5-e5dd4d455f24')
var roleDefinitionIdForSnapshotRG = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7efff54f-a5b4-42b5-a1c5-5411624893ce')
var dataSourceType = 'Microsoft.Compute/disks'
var resourceType = 'Microsoft.Compute/disks'
var retentionDuration = 'P${retentionDays}D'
var repeatingTimeInterval = 'R/2021-05-20T22:00:00+00:00/PT4H'
var roleNameGuidForDisk = guid(resourceGroup().id, roleDefinitionIdForDisk, backupVault.id)
var roleNameGuidForSnapshotRG = guid(resourceGroup().id, roleDefinitionIdForSnapshotRG, backupVault.id)

resource backupVault 'Microsoft.DataProtection/backupVaults@2021-01-01' = {
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

resource backupPolicy 'Microsoft.DataProtection/backupVaults/backupPolicies@2021-01-01' = {
  parent: backupVault
  name: backupPolicyName
  properties: {
    policyRules: [
      {
        backupParameters: {
          backupType: 'Incremental'
          objectType: 'AzureBackupParams'
        }
        trigger: {
          schedule: {
            repeatingTimeIntervals: [
              repeatingTimeInterval
            ]
            timeZone: 'UTC'
          }
          taggingCriteria: [
            {
              tagInfo: {
                tagName: 'Default'
                id: 'Default_'
              }
              taggingPriority: 99
              isDefault: true
            }
          ]
          objectType: 'ScheduleBasedTriggerContext'
        }
        dataStore: {
          dataStoreType: 'OperationalStore'
          objectType: 'DataStoreInfoBase'
        }
        name: 'BackupHourly'
        objectType: 'AzureBackupRule'
      }
      {
        lifecycles: [
          {
            sourceDataStore: {
              dataStoreType: 'OperationalStore'
              objectType: 'DataStoreInfoBase'
            }
            deleteAfter: {
              objectType: 'AbsoluteDeleteOption'
              duration: retentionDuration
            }
          }
        ]
        isDefault: true
        name: 'Default'
        objectType: 'AzureRetentionRule'
        ruleType: 'Retention'
      }
    ]
    datasourceTypes: [
      dataSourceType
    ]
    objectType: 'BackupPolicy'
  }
}

resource computeDisk 'Microsoft.Compute/disks@2020-12-01' = {
  name: diskName
  location: location
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 200
  }
}

resource roleAssignmentForDisk 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleNameGuidForDisk
  properties: {
    roleDefinitionId: roleDefinitionIdForDisk
    principalId: reference(backupVault.id, '2021-01-01', 'Full').identity.principalId
  }
  dependsOn: [
    backupPolicy
    computeDisk
  ]
}

resource roleAssignmentForSnapshotRG 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleNameGuidForSnapshotRG
  properties: {
    roleDefinitionId: roleDefinitionIdForSnapshotRG
    principalId: reference(backupVault.id, '2021-01-01', 'Full').identity.principalId
  }
  dependsOn: [
    backupPolicy
    computeDisk
  ]
}

resource backupInstance 'Microsoft.DataProtection/backupvaults/backupInstances@2021-01-01' = {
  parent: backupVault
  name: diskName
  properties: {
    objectType: 'BackupInstance'
    dataSourceInfo: {
      objectType: 'Datasource'
      resourceID: computeDisk.id
      resourceName: diskName
      resourceType: resourceType
      resourceUri: computeDisk.id
      resourceLocation: location
      datasourceType: dataSourceType
    }
    policyInfo: {
      policyId: backupPolicy.id
      name: backupPolicyName
      policyParameters: {
        dataStoreParametersList: [
          {
            objectType: 'AzureOperationalStoreParameters'
            dataStoreType: 'OperationalStore'
            resourceGroupId: resourceGroup().id
          }
        ]
      }
    }
  }
  dependsOn: [
    roleAssignmentForDisk
    roleAssignmentForSnapshotRG
  ]
}
