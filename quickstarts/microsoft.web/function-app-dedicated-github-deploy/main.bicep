@description('The name of the function app that you wish to create.')
param appName string = 'funtionapp-${uniqueString(resourceGroup().id)}'

@description('The pricing tier for the hosting plan.')
param sku string = 'S1'

@description('The instance size of the hosting plan (small, medium, or large).')
@allowed([
  0
  1
  2
])
param workerSize int = 0

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('The URL for the GitHub repository that contains the project to deploy.')
param repoURL string = 'https://github.com/AzureBytes/functionshttpecho.git'

@description('The branch of the GitHub repository to use.')
param branch string = 'master'

@description('Location for all resources.')
param location string = resourceGroup().location

var functionAppName = appName
var hostingPlanName = '${appName}-plan'
var storageAccountName = '${uniqueString(resourceGroup().id)}functions'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku: {
    name: storageAccountType
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: sku
  }
  properties: {
    targetWorkerSizeId: workerSize
    targetWorkerCount: 1
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
    siteConfig: {
      alwaysOn: true
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};'
        }
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};'
        }
      ]
    }
  }
}

resource functionAppWeb 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  parent: functionApp
  name: 'web'
  properties: {
    repoUrl: repoURL
    branch: branch
    isManualIntegration: true
  }
}
