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
