@description('The location in which the resources should be deployed.')
param location string = resourceGroup().location

param acctName string = 'bicep-with-prereqs-${uniqueString(resourceGroup().id)}'
param dbName string = 'db1'

var storageAccountName = uniqueString(resourceGroup().id, 'bicep-with-prereqs')

resource acct 'Microsoft.DocumentDB/databaseAccounts@2021-01-15' = {
  name: acctName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  location: location
  name: '${acct.name}/${dbName}'
  properties: {
    resource: {
      id: dbName
    }
    options: {
      throughput: 400
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}
