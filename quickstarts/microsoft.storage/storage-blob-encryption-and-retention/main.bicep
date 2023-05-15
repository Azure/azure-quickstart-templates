@description('Storage account name')
param storageAccountName string = uniqueString(resourceGroup().id)

@description('Storage account location')
param location string = resourceGroup().location

@description('Storage account sku')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSku string = 'Standard_LRS'

@description('Storage account kind')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param storageKind string = 'StorageV2'

@description('Storage account access tier, Hot for frequently accessed data or Cool for infreqently accessed data')
@allowed([
  'Hot'
  'Cool'
])
param storageTier string = 'Hot'

@description('Amount of days the soft deleted data is stored and available for recovery')
@minValue(1)
@maxValue(365)
param deleteRetentionPolicy int = 7

@description('Enable blob encryption at rest')
param blobEncryptionEnabled bool = true

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: storageKind
  properties: {
    accessTier: storageTier
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: blobEncryptionEnabled
        }
      }
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storage
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: deleteRetentionPolicy
    }
  }
}
