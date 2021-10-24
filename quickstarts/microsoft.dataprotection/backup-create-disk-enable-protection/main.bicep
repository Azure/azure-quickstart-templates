@description('Name of the Vault')
param vaultName string = 'vault${uniqueString(resourceGroup().id)}'

@description('Change Vault Storage Type (not allowed if the vault has registered backups)')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param vaultStorageRedundancy string = 'GeoRedundant'

@description('Name of the Backup Policy')
param backupPolicyName string = 'diskpolicy${uniqueString(resourceGroup().id)}'

@description('Retention duration in days')
@minValue(1)
@maxValue(35)
param retentionDays int = 30

@description('Name of the Disk')
param diskName string = 'backupdisk${uniqueString(resourceGroup().id)}'

@description('Location for all resources')
param location string = resourceGroup().location

var roleDefinitionIdForDisk = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3e5e47e6-65f7-47ef-90b5-e5dd4d455f24')
var roleDefinitionIdForSnapshotRG = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7efff54f-a5b4-42b5-a1c5-5411624893ce')
var dataSourceType = 'Microsoft.Compute/disks'
var resourceType = 'Microsoft.Compute/disks'
var retentionDuration = 'P${retentionDays}D'
var repeatingTimeInterval = 'R/2021-05-20T22:00:00+00:00/PT4H'
var roleNameGuidForDisk_var = guid(resourceGroup().id, roleDefinitionIdForDisk, vaultName_resource.id)
var roleNameGuidForSnapshotRG_var = guid(resourceGroup().id, roleDefinitionIdForSnapshotRG, vaultName_resource.id)

resource vaultName_resource 'Microsoft.DataProtection/backupVaults@2021-01-01' = {
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

resource vaultName_backupPolicyName 'Microsoft.DataProtection/backupVaults/backupPolicies@2021-01-01' = {
  parent: vaultName_resource
  name: '${backupPolicyName}'
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

resource diskName_resource 'Microsoft.Compute/disks@2020-12-01' = {
  name: diskName
  location: location
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: 200
  }
}

resource roleNameGuidForDisk 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleNameGuidForDisk_var
  properties: {
    roleDefinitionId: roleDefinitionIdForDisk
    principalId: reference(vaultName_resource.id, '2021-01-01', 'Full').identity.principalId
  }
  dependsOn: [
    vaultName_backupPolicyName
    diskName_resource
  ]
}

resource roleNameGuidForSnapshotRG 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleNameGuidForSnapshotRG_var
  properties: {
    roleDefinitionId: roleDefinitionIdForSnapshotRG
    principalId: reference(vaultName_resource.id, '2021-01-01', 'Full').identity.principalId
  }
  dependsOn: [
    vaultName_backupPolicyName
    diskName_resource
  ]
}

resource vaultName_diskName 'Microsoft.DataProtection/backupvaults/backupInstances@2021-01-01' = {
  parent: vaultName_resource
  name: '${diskName}'
  properties: {
    objectType: 'BackupInstance'
    dataSourceInfo: {
      objectType: 'Datasource'
      resourceID: diskName_resource.id
      resourceName: diskName
      resourceType: resourceType
      resourceUri: diskName_resource.id
      resourceLocation: location
      datasourceType: dataSourceType
    }
    policyInfo: {
      policyId: vaultName_backupPolicyName.id
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
    roleNameGuidForDisk
    roleNameGuidForSnapshotRG
  ]
}
