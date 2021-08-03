@description('Location of the workspace')
param location string = resourceGroup().location

@description('Name of the workspace')
param name string
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])

@description('Sku of the workspace')
param sku string

@description('The workspace data retention in days, between 30 and 730')
@minValue(7)
@maxValue(730)
param retentionInDays int

@description('Solutions to add to workspace')
param solutions array = []

@description('Name of automation account to link to workspace')
param automationAccountName string = ''

@description('Datasources to add to workspace')
param dataSources array = []

@description('Enable lock to prevent accidental deletion')
param enableDeleteLock bool = false

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account name. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountName string = ''

@description('Storage account resource group. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountResourceGroup string = ''

var lockName = '${logAnalyticsWorkspace.name}-lck'
var diagnosticsName = '${logAnalyticsWorkspace.name}-dgs'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

resource logAnalyticsSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution.name}(${logAnalyticsWorkspace.name})'
  location: location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: '${solution.name}(${logAnalyticsWorkspace.name})'
    product: solution.product
    publisher: solution.publisher
    promotionCode: solution.promotionCode
  }
}]

resource logAnalyticsAutomation 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = if (!empty(automationAccountName)) {
  parent: logAnalyticsWorkspace
  name: 'Automation'
  properties: {
    resourceId: resourceId('Microsoft.Automation/automationAccounts', automationAccountName)
  }
}

resource logAnalyticsDataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [for dataSource in dataSources: {
  parent: logAnalyticsWorkspace
  name: dataSource.name
  kind: dataSource.kind
  properties: dataSource.properties
}]

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: logAnalyticsWorkspace

  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = if (enableDiagnostics) {
  name: diagnosticsName
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: resourceId(diagnosticStorageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', diagnosticStorageAccountName)
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
