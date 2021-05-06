@description('The location in which the resources should be deployed.')
param location string = resourceGroup().location

param dbName string = 'db1'

resource acct 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' = {
  name: 'acct1'
  properties: {
    enableFreeTier: true
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
  // 2021-04-15
  name: '${acct.name}/$dbName'
  properties: {
    resource: {
      id: dbName
    }
    options: {
      throughput: 400
    }
  }
}
