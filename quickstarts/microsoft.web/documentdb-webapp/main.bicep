@description('The Azure Cosmos DB database account name.')
param databaseAccountName string

@description('The name of the App Service Plan that will host the Web App.')
param appSvcPlanName string

@description('The instance size of the App Service Plan.')
param svcPlanSize string = 'F1'

@description('The pricing tier of the App Service plan.')
@allowed([
  'Free'
  'Shared'
  'Basic'
  'Standard'
  'Premium'
])
param svcPlanSku string = 'Free'

@description('The name of the Web App.')
param webAppName string

@description('Location for all resources.')
param location string = resourceGroup().location

var databaseAccountTier = 'Standard'

resource databaseAccount'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
  name: databaseAccountName
  location: location
  properties: {
    databaseAccountOfferType: databaseAccountTier
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
  }
}

resource appSvcPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appSvcPlanName
  location: location
  sku: {
    name: svcPlanSize
    tier: svcPlanSku
    capacity: 1
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appSvcPlan.id
    httpsOnly: true
    
    siteConfig: {
      ftpsState: 'FtpsOnly'
      phpVersion: 'off'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'DOCUMENTDB_ENDPOINT'
          value: databaseAccount.properties.documentEndpoint
        }
        {
          name: 'DOCUMENTDB_PRIMARY_KEY'
          value: databaseAccount.listKeys().primaryMasterKey
        }
      ]
    }
    
  }
}
