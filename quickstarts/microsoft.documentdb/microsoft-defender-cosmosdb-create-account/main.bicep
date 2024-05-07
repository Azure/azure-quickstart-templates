@description('Cosmos DB account name. max length 44 characters, only digits and letters, lowercase')
param accountName string = 'cosmosdb-${uniqueString(resourceGroup().id)}'

@description('Location for your CosmosDB account.')
param location string = resourceGroup().location

@description('Enable or disable Microsoft Defender for Azure Cosmos DB.')
param microsoftDefenderForAzureCosmosDBEnabled bool = true

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2020-09-01' = {
  name: accountName
  location: location
  properties: {
    locations: [
      {
        locationName: location
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

resource defenderEnabled 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = if (microsoftDefenderForAzureCosmosDBEnabled) {
  scope: cosmosDbAccount
  name: 'current'
  properties: {
    isEnabled: true
  }
}

output cosmosDbAccountName string = accountName
output cosmosDbAccountId string = cosmosDbAccount.id
