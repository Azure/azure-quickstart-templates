@description('The name of your CosmosDB account')
param name string = uniqueString('cosmosdb', resourceGroup().id)

@description('Location for your CosmosDB account')
param location string = resourceGroup().location

@description('CosmosDB account tier')
param tier string = 'Standard'

resource dbaccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: name
  location: location
  properties: {
    locations: [
      {
        locationName: location
      }
    ]
    databaseAccountOfferType: tier
  }
}
