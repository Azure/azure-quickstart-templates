@description('The name of you Web Site.')
param siteName string = 'WebApp-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The pricing tier for the hosting plan.')
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
param sku string = 'F1'

@description('The instance size of the hosting plan (small, medium, or large).')
@allowed([
  '0'
  '1'
  '2'
])
param workerSize string = '0'

@description('The URL for the GitHub repository that contains the project to deploy.')
param repoURL string = 'https://github.com/Azure-Samples/app-service-web-html-get-started.git'

@description('The branch of the GitHub repository to use.')
param branch string = 'master'

var hostingPlanName = 'hpn-${resourceGroup().name}'

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: sku
    capacity: int(workerSize)
  }
  properties: {
  }
}

resource site 'Microsoft.Web/sites@2023-01-01' = {
  name: siteName
  location: location
  properties: {
  }
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2023-01-01' = {
  parent: site
  name: 'web'
  properties: {
    repoUrl: repoURL
    branch: branch
    isManualIntegration: true
  }
}
