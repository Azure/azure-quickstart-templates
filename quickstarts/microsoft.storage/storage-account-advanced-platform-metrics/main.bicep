metadata description = 'Deploy a StorageV2 account with advanced platform metrics enabled for all blob containers.'

@description('Globally unique storage account name containing only lowercase letters and numbers.')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stapm${uniqueString(resourceGroup().id)}'

@description('Azure region for the storage account. Advanced platform metrics and the selected SKU must be available in this region.')
param location string = resourceGroup().location

@description('Storage redundancy SKU for a standard StorageV2 account. Availability depends on the selected region.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountSku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource advancedPlatformMetrics 'Microsoft.Storage/storageAccounts/advancedPlatformMetrics@2026-09-01' = {
  parent: storageAccount
  name: 'ContainerLevelCapacityMetrics'
  properties: {
    enabled: true
    ruleConfig: {
      filterType: 'AllContainersFilter'
      filterValues: []
    }
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output storageAccountBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
