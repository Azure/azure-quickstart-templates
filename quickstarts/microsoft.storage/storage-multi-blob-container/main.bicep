@description('Specifies the name of the Azure Storage account.')
param storageAccountName string

@description('Specifies the prefix of the blob container names.')
param containerPrefix string = 'logs'

@description('Specifies the location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = [for i in range(0, 3): {
  name: '${sa.name}/default/${containerPrefix}${i}'
}]
