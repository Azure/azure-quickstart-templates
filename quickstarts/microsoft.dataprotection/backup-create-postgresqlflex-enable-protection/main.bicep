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

@description('Name of the PgFlex server')
param pgFlexServerName string = 'pgflex${uniqueString(resourceGroup().id)}'

@description('Location for all resources')
param location string = resourceGroup().location

var roleDefinitionIdForPgFlex = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'c088a766-074b-43ba-90d4-1fb21feae531')
var roleDefinitionIdForDiscovery = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var dataSourceType = 'Microsoft.DBforPostgreSQL/flexibleServers'
var resourceType = 'Microsoft.DBforPostgreSQL/flexibleServers'
var retentionDuration = 'P${retentionDays}D'
var repeatingTimeInterval = 'R/2021-05-20T22:00:00+00:00/PT12H'
var roleNameGuidForPgFlex = guid(resourceGroup().id, roleDefinitionIdForPgFlex, backupVault.id)
var roleNameGuidForDiscovery = guid(resourceGroup().id, roleDefinitionIdForDiscovery, backupVault.id)

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'Basic'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'GeneralPurpose'

@description('Azure database for PostgreSQL Flexible Server sku name ')
param skuName string = 'Standard_D2ds_v4'

@description('Azure database for PostgreSQL Flexible Server Storage Size in GB ')
param storageSize int = 32

@description('PostgreSQL version')
@allowed([
  '11'
  '12'
  '13'
  '14'
])
param postgresqlVersion string = '14'

@description('PostgreSQL Flexible Server backup retention days')
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

@description('Active Directory Authetication')
@allowed([
  'Disabled'
  'Enabled'
])
param isActiveDirectoryAuthEnabled string = 'Enabled'

@description('PostgreSQL Authetication')
@allowed([
  'Disabled'
  'Enabled'
])
param isPostgreSQLAuthEnabled string = 'Enabled'

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

resource pgFlexServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: pgFlexServerName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    createMode: 'Default'
    version: postgresqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    authConfig: {
      activeDirectoryAuth: isActiveDirectoryAuthEnabled
      passwordAuth: isPostgreSQLAuthEnabled
      tenantId: subscription().tenantId
    }
      storage: {
        storageSizeGB: storageSize
      }
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
  name: roleNameGuidForPgFlex
  properties: {
    principalId: backupVault.identity.principalId
    roleDefinitionId: roleDefinitionIdForPgFlex
  }
  dependsOn: [
    backupPolicy
    pgFlexServer
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
    pgFlexServer
  ]
}

resource backupInstance 'Microsoft.DataProtection/backupVaults/backupInstances@2023-12-01' = {
  parent: backupVault
  name: pgFlexServerName
  properties: {
    objectType: 'BackupInstance'
    dataSourceInfo: {
      objectType: 'Datasource'
      resourceID: pgFlexServer.id
      resourceName: pgFlexServerName
      resourceType: resourceType
      resourceUri: pgFlexServer.id
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
