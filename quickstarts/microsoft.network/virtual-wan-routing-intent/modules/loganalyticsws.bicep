param logAnalyticsWorkspaceName string
param location string
param logAnalyticsWorkspaceSKU string
//param logAnalyticsWorkspaceRetentionDays int

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSKU
    }
    //retentionInDays: logAnalyticsWorkspaceRetentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output LogAnalyticsWorkspaceID string = logAnalyticsWorkspace.id 
