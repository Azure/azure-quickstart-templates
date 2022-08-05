@description('Cosmos DB account name, max length 44 characters')
param accountName string = 'sql-${toLower(uniqueString(resourceGroup().id))}'

@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}
