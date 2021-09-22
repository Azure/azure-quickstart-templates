@description('Application Name')
@maxLength(30)
param applicationName string = 'to-do-app${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
@description('App Service Plan\'s pricing tier. Details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
param appServicePlanTier string = 'F1'

@minValue(1)
@maxValue(3)
@description('App Service Plan\'s instance count')
param appServicePlanInstances int = 1

@description('The URL for the GitHub repository that contains the project to deploy.')
param repositoryUrl string = 'https://github.com/Azure-Samples/cosmos-dotnet-core-todo-app.git'

@description('The branch of the GitHub repository to use.')
param branch string = 'main'

@description('The Cosmos DB database name.')
param databaseName string = 'Tasks'

@description('The Cosmos DB container name.')
param containerName string = 'Items'

var cosmosAccountName = toLower(applicationName)
var websiteName = applicationName
var hostingPlanName = applicationName

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: cosmosAccountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: appServicePlanTier
    capacity: appServicePlanInstances
  }
}

resource website 'Microsoft.Web/sites@2020-06-01' = {
  name: websiteName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'CosmosDb:Account'
          value: cosmosAccount.properties.documentEndpoint
        }
        {
          name: 'CosmosDb:Key'
          value: cosmosAccount.listKeys().primaryMasterKey
        }
        {
          name: 'CosmosDb:DatabaseName'
          value: databaseName
        }
        {
          name: 'CosmosDb:ContainerName'
          value: containerName
        }
      ]
    }
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2020-06-01' = {
  name: '${website.name}/web'
  properties: {
    repoUrl: repositoryUrl
    branch: branch
    isManualIntegration: true
  }
}
