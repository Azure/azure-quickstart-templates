metadata description = 'Deploy a geo-redundant StorageV2 account by default with default-deny network access and advanced platform metrics enabled for all blob containers.'

@description('Globally unique storage account name containing only lowercase letters and numbers.')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stapm${uniqueString(resourceGroup().id)}'

@description('Azure region for the storage account. Advanced platform metrics and the selected SKU must be available in this region.')
param location string = resourceGroup().location

@description('Storage redundancy SKU for a standard StorageV2 account. Defaults to geo-redundant storage. LRS and ZRS do not provide cross-region replication. Availability depends on the selected region.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountSku string = 'Standard_GRS'

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
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
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
