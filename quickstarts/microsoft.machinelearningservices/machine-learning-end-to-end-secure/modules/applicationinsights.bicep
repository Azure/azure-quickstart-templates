// Creates an Application Insights instance as dependency for Azure ML
@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Tags to add to the resources')
param tags object = {}

@description('Application Insights resource name')
param applicationInsightsName string

@description('Log Analytics resource name')
param logAnalyticsWorkspaceName string 

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    Flow_Type: 'Bluefield'
  }
}

output applicationInsightsId string = applicationInsights.id
