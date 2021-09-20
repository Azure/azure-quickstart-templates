param location string = resourceGroup().location
param logAnalyticsWorkspaceName string = 'la-${uniqueString(resourceGroup().id)}'

var vmInsights = {
  name: 'VMInsights(${logAnalyticsWorkspaceName})'
  galleryName: 'VMInsights'
}
var containerInsights = {
  name: 'ContainerInsights(${logAnalyticsWorkspaceName})'
  galleryName: 'ContainerInsights'
}

var environmentName = 'Production'
var costCenterName = 'IT'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: {
    Environment: environmentName
    CostCenter: costCenterName
  }
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource logAnalyticsWorkspaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  scope: logAnalyticsWorkspace
  name: 'diagnosticSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

resource solutionsVMInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: vmInsights.name
  location: location
  dependsOn: [
    logAnalyticsWorkspace
  ]
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: vmInsights.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${vmInsights.galleryName}'
    promotionCode: ''
  }
}

resource solutionsContainerInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: containerInsights.name
  location: location
  dependsOn: [
    logAnalyticsWorkspace
  ]
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: containerInsights.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${containerInsights.galleryName}'
    promotionCode: ''
  }
}
