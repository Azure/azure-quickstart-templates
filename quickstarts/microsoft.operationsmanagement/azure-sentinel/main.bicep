param location string = resourceGroup().location
param sentinelName string = 'sentinel'

@minValue(30)
@maxValue(730)
param retentionInDays int = 90

var workspaceName = '${location}-${sentinelName}-${uniqueString(resourceGroup().id)}'
var solutionName = 'SecurityInsights(${sentinelWorkspace.name})'

resource sentinelWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
  }
}

resource sentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: solutionName
  location: location
  properties: {
    workspaceResourceId: sentinelWorkspace.id
  }
  plan: {
    name: solutionName
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
}

