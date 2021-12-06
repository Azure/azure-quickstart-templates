@description('p1 description')
param p1 string

resource resource1 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: 'storageaccount1'
  location: 'westus'
  properties: {
    allowBlobPublicAccess: true
  }
  kind: 'BlobStorage'
  sku: {
    name: 'Premium_LRS'
  }
}

resource resource2 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: 'storageaccount2'
  location: 'westus'
  properties: {
    allowBlobPublicAccess: true
  }
  kind: 'BlobStorage'
  sku: {
    name: 'Premium_LRS'
  }
}

module module1a 'Module1.bicep' = {
  name: 'myModule1a'
}

module module1b 'Module1.bicep' = {
  name: 'myModule1b'
}
