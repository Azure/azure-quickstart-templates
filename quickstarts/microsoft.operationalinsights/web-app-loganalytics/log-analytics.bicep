param location string = resourceGroup().location

param appName string
var logAnalyticsName = toLower('la-${appName}')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsName
  location: location
  tags: {
    displayName: 'Log Analytics'
    ProjectName: appName
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 120
  }
}
output logAnalaticsWorkspaceResourceID string = logAnalyticsWorkspace.id
