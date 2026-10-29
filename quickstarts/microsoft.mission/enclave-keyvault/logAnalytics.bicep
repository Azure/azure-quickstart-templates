param name string
param location string
param skuName string = 'PerGB2018'
param retentionInDays int = 90
param dailyQuotaGb int = -1
param publicNetworkAccessForIngestion string = 'Disabled'
param publicNetworkAccessForQuery string = 'Disabled'
param enableDiagnostics bool = false
param diagnosticLogAnalyticsWorkspaceId string = ''
param tagsByResource object = {}

// Linked storage params
param linkedStorageAccountId string = ''

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  tags: contains(tagsByResource, 'Microsoft.OperationalInsights/workspaces') ? tagsByResource['Microsoft.OperationalInsights/workspaces'] : {}
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: retentionInDays
    workspaceCapping: dailyQuotaGb > 0 ? {
      dailyQuotaGb: dailyQuotaGb
    } : null
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: true
    }
    defaultDataCollectionRuleResourceId: null
  }
}

// Linked storage account for custom log ingestion and query audit
resource linkedStorage 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = if (!empty(linkedStorageAccountId)) {
  parent: workspace
  name: 'CustomLogs'
  properties: {
    storageAccountIds: [
      linkedStorageAccountId
    ]
  }
}

resource linkedStorageQuery 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = if (!empty(linkedStorageAccountId)) {
  parent: workspace
  name: 'Query'
  properties: {
    storageAccountIds: [
      linkedStorageAccountId
    ]
  }
}

// Diagnostic settings for workspace operations
resource workspaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && !empty(diagnosticLogAnalyticsWorkspaceId)) {
  name: '${name}-diagnostics'
  scope: workspace
  properties: {
    workspaceId: diagnosticLogAnalyticsWorkspaceId
    logs: [
      { categoryGroup: 'allLogs', enabled: true }
      { categoryGroup: 'audit', enabled: true }
    ]
    metrics: [
      { category: 'AllMetrics', enabled: true }
    ]
  }
}

output workspaceId string = workspace.id
output workspaceCustomerId string = workspace.properties.customerId
