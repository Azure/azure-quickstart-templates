// Location for all resources.
param location string = resourceGroup().location
param cacheAccountName string

resource cacheAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: cacheAccountName
  location: location
  tags: {
    displayName: 'Storage Account'
  }
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'Storage'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: false
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource diagsAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'diags${uniqueString(resourceGroup().id)}'
  location: location
  tags: {
    displayName: 'Storage Account'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {}
}

output diagAccountId string = diagsAccount.id
output cacheAccountName string = cacheAccount.name
output cacheAccountId string = cacheAccount.id
