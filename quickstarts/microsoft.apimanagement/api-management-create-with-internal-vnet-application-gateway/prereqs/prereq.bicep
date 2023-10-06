@description('Location in which resources will be created')
param location string = resourceGroup().location
param log_analytics_workspace_name string

var log_analtytics_resource_group = resourceGroup().name

resource log_analytics_workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: log_analytics_workspace_name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output logAnalyticsWorkspaceId string = resourceId(log_analtytics_resource_group, 'Microsoft.OperationalInsights/workspaces', log_analytics_workspace_name)
