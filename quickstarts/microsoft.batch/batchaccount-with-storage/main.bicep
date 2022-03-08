@description('Batch Account Name')
param batchAccountName string = '${toLower(uniqueString(resourceGroup().id))}batch'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountsku string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

var storageAccount_var = '${uniqueString(resourceGroup().id)}storage'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccount_var
  location: location
  sku: {
    name: storageAccountsku
  }
  kind: 'StorageV2'
  tags: {
    ObjectName: storageAccount_var
  }
  properties: {}
}

resource batchAccount 'Microsoft.Batch/batchAccounts@2021-06-01' = {
  name: batchAccountName
  location: location
  tags: {
    ObjectName: batchAccountName
  }
  properties: {
    autoStorage: {
      storageAccountId: storageAccount.id
    }
  }
}

output storageAccount string = storageAccount_var
output batchAccountName string = batchAccountName
