@description('Name of the Media Services account. A Media Services account name is globally unique, all lowercase letters or numbers with no spaces.')
param mediaServiceName string = 'mediaserv${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'

resource mediaService 'Microsoft.Media/mediaservices@2021-06-01' = {
  name: mediaServiceName
  location: location
  properties: {
    storageAccounts: [
      {
        id: storageAccount.id
        type: 'Primary'
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
