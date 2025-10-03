@description('Name of the Vault')
param vaultName string = 'vault${uniqueString(resourceGroup().id)}'

@description('Change Vault Storage Type (not allowed if the vault has registered backups)')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param vaultStorageRedundancy string = 'LocallyRedundant'

@description('Name of the Backup Policy')
param backupPolicyName string = 'policy${uniqueString(resourceGroup().id)}'

@description('Retention duration in days')
@minValue(1)
@maxValue(35)
param retentionDays int = 30

@description('Name of the MySQL Flexible Server')
param mysqlFlexServerName string = 'mysqlflex${uniqueString(resourceGroup().id)}'

@description('Location for all resources')
param location string = resourceGroup().location

var roleDefinitionIdForMySqlFlex = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'd18ad5f3-1baf-4119-b49b-d944edb1f9d0')
var roleDefinitionIdForDiscovery = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var dataSourceType = 'Microsoft.DBforMySQL/flexibleServers'
var resourceType = 'Microsoft.DBforMySQL/flexibleServers'
var retentionDuration = 'P${retentionDays}D'
var repeatingTimeInterval = 'R/2021-05-20T22:00:00+00:00/PT12H'
var roleNameGuidForMySqlFlex = guid(resourceGroup().id, roleDefinitionIdForMySqlFlex, backupVault.id)
var roleNameGuidForDiscovery = guid(resourceGroup().id, roleDefinitionIdForDiscovery, backupVault.id)

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for MySQL sku name ')
param skuName string = 'Standard_B1s'

@description('Azure database for MySQL pricing tier')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'Burstable'

@description('Azure database for MySQL Flexible Server Storage Size in GB ')
param storageSizeGB int = 20

@description('Azure database for MySQL storage Iops')
param storageIops int = 360

@description('MySQL version')
@allowed([
  '5.7'
  '8.0.21'
])
param mysqlVersion string = '8.0.21'

@description('MySQL Flexible Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string = 'Disabled'

@description('High Availability Mode')
@allowed([
  'Disabled'
  'ZoneRedundant'
  'SameZone'
])
param haMode string = 'Disabled'

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
          backupType: 'full'
          objectType: 'AzureBackupParams'
        }
        trigger: {
          schedule: {
            repeatingTimeIntervals: [
              repeatingTimeInterval
            ]
          }
          taggingCriteria: [
            {
              tagInfo: {
                tagName: 'Default'
              }
              taggingPriority: 99
              isDefault: true
            }
          ]
          objectType: 'ScheduleBasedTriggerContext'
        }
        dataStore: {
          dataStoreType: 'VaultStore'
          objectType: 'DataStoreInfoBase'
        }
        name: 'BackupHourly'
        objectType: 'AzureBackupRule'
      }
      {
        lifecycles: [
          {
            sourceDataStore: {
              dataStoreType: 'VaultStore'
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
      }
    ]
    datasourceTypes: [
      dataSourceType
    ]
    objectType: 'BackupPolicy'
  }
}

resource mySqlFlexServer 'Microsoft.DBforMySQL/flexibleServers@2023-12-01-preview' = {
  name: mysqlFlexServerName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storage: {
      autoGrow: 'Enabled'
      iops: storageIops
      storageSizeGB: storageSizeGB
    }
    createMode: 'Default'
    version: mysqlVersion
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: haMode
    }
  }
}

resource roleAssignmentForPgFlex 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleNameGuidForMySqlFlex
  properties: {
    principalId: backupVault.identity.principalId
    roleDefinitionId: roleDefinitionIdForMySqlFlex
  }
  dependsOn: [
    backupPolicy
    mySqlFlexServer
  ]
}

resource roleAssignmentForDiscovery 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleNameGuidForDiscovery
  properties: {
    roleDefinitionId: roleDefinitionIdForDiscovery
    principalId: backupVault.identity.principalId
  }
  dependsOn: [
    backupPolicy
    mySqlFlexServer
  ]
}

resource backupInstance 'Microsoft.DataProtection/backupVaults/backupInstances@2023-12-01' = {
  parent: backupVault
  name: mysqlFlexServerName
  properties: {
    objectType: 'BackupInstance'
    dataSourceInfo: {
      objectType: 'Datasource'
      resourceID: mySqlFlexServer.id
      resourceName: mysqlFlexServerName
      resourceType: resourceType
      resourceUri: mySqlFlexServer.id
      resourceLocation: location
      datasourceType: dataSourceType
    }
    policyInfo: {
      policyId: backupPolicy.id
    }
  }
  dependsOn: [
  ]
}
