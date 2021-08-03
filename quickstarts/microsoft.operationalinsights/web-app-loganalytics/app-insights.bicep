param location string = resourceGroup().location
param appName string
param logAnalaticsWorkspaceResourceID string

var appInsightName = toLower('appi-${appName}')

resource appInsights 'microsoft.insights/components@2020-02-02-preview' = {
  name: appInsightName
  location: location
  kind: 'string'
  tags: {
    displayName: 'AppInsight'
    ProjectName: appName
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalaticsWorkspaceResourceID
  }
}
output APPINSIGHTS_INSTRUMENTATIONKEY string = appInsights.properties.InstrumentationKey
