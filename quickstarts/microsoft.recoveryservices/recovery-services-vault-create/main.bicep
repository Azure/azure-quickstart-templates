@description('Name of the Vault')
param vaultName string

@description('Enable CRR (Works if vault has not registered any backup instance)')
param enableCRR bool = true

@description('Change Vault Storage Type (Works if vault has not registered any backup instance)')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param vaultStorageType string = 'GeoRedundant'

@description('Location for all resources.')
param location string = resourceGroup().location

var skuName = 'RS0'
var skuTier = 'Standard'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2020-02-02' = {
  name: vaultName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {}
}

resource vaultName_vaultstorageconfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2020-02-02' = {
  parent: recoveryServicesVault
  name: 'vaultstorageconfig'
  properties: {
    StorageModelType: vaultStorageType
    CrossRegionRestoreFlag: enableCRR
  }
}
