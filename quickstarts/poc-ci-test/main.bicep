targetScope = 'resourceGroup'

@description('Location for the storage account')
param location string = resourceGroup().location

@description('Name of the storage account')
param storageAccountName string = 'stpoctest${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

output storageAccountId string = storageAccount.id
