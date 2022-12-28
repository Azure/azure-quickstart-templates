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
@maxValue(360)
param retentionDays int = 30

@description('Name of the Storage Account')
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}'

@description('Location for all resources')
param location string = resourceGroup().location

var roleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1')
var dataSourceType = 'Microsoft.Storage/storageAccounts/blobServices'
var resourceType = 'Microsoft.Storage/storageAccounts'
var retentionDuration = 'P${retentionDays}D'

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

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(backupVault.id, roleDefinitionId, storageAccount.id)
  scope: storageAccount
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: reference(backupVault.id, '2021-01-01', 'Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource backupInstance 'Microsoft.DataProtection/backupvaults/backupInstances@2021-01-01' = {
  parent: backupVault
  name: storageAccountName
  properties: {
    objectType: 'BackupInstance'
    dataSourceInfo: {
      objectType: 'Datasource'
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
    }
  }
  dependsOn: [
    roleAssignment
  ]
}
