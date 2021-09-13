@description('Recovery Services vault name')
param vaultName string = uniqueString(resourceGroup().id)

@description('Location of Recovery Services vault')
param location string = resourceGroup().location

@description('Enable system identity for Recovery Services vault')
param enableSystemIdentity bool = false

@description('Enable system identity for Recovery Services vault')
@allowed([
  'Standard'
  'RS0'
])
param sku string = 'RS0'

@description('Storage replication type for Recovery Services vault')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
param storageType string = 'GeoRedundant'

@description('Enable cross region restore')
param enablecrossRegionRestore bool = false

@description('Array containing backup policies')
@metadata({
  policyName: 'Backup policy name'
  properties: 'Object containing backup policy settings'
})
param backupPolicies array = []

@description('Enable delete lock')
param enableDeleteLock bool = false

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param logAnalyticsWorkspaceId string = ''

var lockName = '${vault.name}-lck'
var diagnosticsName = '${vault.name}-dgs'

resource vault 'Microsoft.RecoveryServices/vaults@2021-06-01' = {
  name: vaultName
  location: location
  identity: {
    type: enableSystemIdentity ? 'SystemAssigned' : 'None'
  }
  properties: {}
  sku: {
    name: sku
    tier: 'Standard'
  }
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-06-01' = [for policy in backupPolicies: {
  parent: vault
  name: policy.policyName
  location: location
  properties: policy.properties
}]

resource vaultConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2021-04-01' = {
  name: '${vault.name}/VaultStorageConfig'
  properties: {
    crossRegionRestoreFlag: enablecrossRegionRestore
    storageType: storageType
  }
}

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: vault
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

resource diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (enableDiagnostics) {
  scope: vault
  name: diagnosticsName
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticStorageAccountId
    logs: [
      {
        category: 'AzureBackupReport'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryJobs'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryEvents'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicatedItems'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicationStats'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryRecoveryPoints'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryReplicationDataUploadRate'
        enabled: true
      }
      {
        category: 'AzureSiteRecoveryProtectedDiskDataChurn'
        enabled: true
      }
      {
        category: 'CoreAzureBackup'
        enabled: true
      }
      {
        category: 'CoreAzureBackup'
        enabled: true
      }
      {
        category: 'AddonAzureBackupJobs'
        enabled: true
      }
      {
        category: 'AddonAzureBackupAlerts'
        enabled: true
      }
      {
        category: 'AddonAzureBackupPolicy'
        enabled: true
      }
      {
        category: 'AddonAzureBackupStorage'
        enabled: true
      }
      {
        category: 'AddonAzureBackupProtectedInstance'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Health'
        enabled: true
      }
    ]
  }
}

output name string = vault.name
output id string = vault.id
output systemIdentityPrincipalId string = enableSystemIdentity ? vault.identity.principalId : 'None'
