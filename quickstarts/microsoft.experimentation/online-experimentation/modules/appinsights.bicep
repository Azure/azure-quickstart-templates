metadata description = 'Creates application insights.'
param name string
param logAnalyticsWorkspaceName string
param location string = resourceGroup().location
param tags object = {}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview'  existing = {
  name: logAnalyticsWorkspaceName
}

output appInsightsId string = applicationInsights.id
output appInsightsConnectionString string = applicationInsights.properties.ConnectionString
