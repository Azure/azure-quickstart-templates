@description('The name of the web app that you wish to create.')
param siteName string

@description('The name of the App Service plan to use for hosting the web app.')
param hostingPlanName string = 'viewerHost'

@description('The pricing tier for the hosting plan.')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
])
param sku string = 'F1'

@description('The URL for the GitHub repository that contains the project to deploy.')
param repoURL string = 'https://github.com/Azure-Samples/azure-event-grid-viewer.git'

@description('The branch of the GitHub repository to use.')
param branch string = 'master'

@description('Location for all resources.')
param location string = resourceGroup().location

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: sku
    capacity: 0
  }
  properties: {}
}

resource site 'Microsoft.Web/sites@2023-01-01' = {
  name: siteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlanName
    httpsOnly: true
    siteConfig: {
      ftpsState: 'FtpsOnly'
      webSocketsEnabled: true
      minTlsVersion: '1.2'
    }
  }
  dependsOn: [
    hostingPlan
  ]
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2023-01-01'= {
  parent: site
  name: 'web'
  properties: {
    repoUrl: repoURL
    branch: branch
    isManualIntegration: true
  }
}

output siteEventUri string = 'https://${site.properties.defaultHostName}/api/updates'
