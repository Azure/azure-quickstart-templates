@description('Name of the Vault')
param vaultName string = 'vault${uniqueString(resourceGroup().id)}'

@description('Change Vault Storage Type (not allowed if the vault has registered backups)')
@allowed([
  'LocallyRedundant'
  'ZonallyRedundant'
  'GeoRedundant'
])
param vaultStorageRedundancy string = 'GeoRedundant'

@description('Name of the Backup Policy')
param backupPolicyName string = 'policy${uniqueString(resourceGroup().id)}'

@description('Retention duration in days')
@minValue(1)
@maxValue(360)
param retentionDays int = 30

@description('Name of the Storage Account')
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}'

@description('A new GUID used to identify the role assignment')
param roleNameGuid string = newGuid()

@description('Location for all resources')
param location string = resourceGroup().location

var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1')
var dataSourceType = 'Microsoft.Storage/storageAccounts/blobServices'
var resourceType = 'Microsoft.Storage/storageAccounts'
var retentionDuration = 'P${retentionDays}D'

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

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
}

resource roleNameGuid_resource 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleNameGuid
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: reference(vaultName_resource.id, '2021-01-01', 'Full').identity.principalId
  }
  dependsOn: [
    vaultName_backupPolicyName
    storageAccountName_resource
  ]
}

resource vaultName_storageAccountName 'Microsoft.DataProtection/backupvaults/backupInstances@2021-01-01' = {
  parent: vaultName_resource
  name: '${storageAccountName}'
  properties: {
    objectType: 'BackupInstance'
    dataSourceInfo: {
      objectType: 'Datasource'
      resourceID: storageAccountName_resource.id
      resourceName: storageAccountName
      resourceType: resourceType
      resourceUri: storageAccountName_resource.id
      resourceLocation: location
      datasourceType: dataSourceType
    }
    policyInfo: {
      policyId: vaultName_backupPolicyName.id
      name: backupPolicyName
    }
  }
  dependsOn: [
    roleNameGuid_resource
  ]
}
