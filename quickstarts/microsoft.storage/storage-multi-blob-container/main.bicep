@description('Specifies the name of the Azure Storage account.')
param storageAccountName string

@description('Specifies the prefix of the blob container names.')
@minLength(2)
param containerPrefix string

@description('Specifies the number of blob containers to create.')
param numberOfContainers int

@description('Specifies the location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: sa
  name: 'default'
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for i in range(0, numberOfContainers): {
  parent: blobServices
  name: '${containerPrefix}${i}'
}]
