@description('Location of the automation account')
param location string = resourceGroup().location

@description('Automation account name')
param name string

@description('Automation account sku')
@allowed([
  'Free'
  'Basic'
])
param sku string = 'Basic'

@description('Modules to import into automation account')
@metadata({
  name: 'Module name'
  version: 'Module version or specify latest to get the latest version'
  uri: 'Module package uri, e.g. https://www.powershellgallery.com/api/v2/package'
})
param modules array = []

@description('Runbooks to import into automation account')
@metadata({
  runbookName: 'Runbook name'
  runbookUri: 'Runbook URI'
  runbookType: 'Runbook type: Graph, Graph PowerShell, Graph PowerShellWorkflow, PowerShell, PowerShell Workflow, Script'
  logProgress: 'Enable progress logs'
  logVerbose: 'Enable verbose logs'
})
param runbooks array = []

@description('Enable delete lock')
param enableDeleteLock bool = false

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account name. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountName string = ''

@description('Storage account resource group. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountResourceGroup string = ''

@description('Log analytics workspace name. Only required if enableDiagnostics is set to true.')
param logAnalyticsWorkspaceName string = ''

@description('Log analytics workspace resource group. Only required if enableDiagnostics is set to true.')
param logAnalyticsResourceGroup string = ''

@description('Log analytics workspace subscription id (if differs from current subscription). Only required if enableDiagnostics is set to true.')
param logAnalyticsSubscriptionId string = subscription().subscriptionId

var lockName = '${automationAccount.name}-lck'
var diagnosticsName = '${automationAccount.name}-dgs'

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: sku
    }
  }
}

resource automationAccountModules 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = [for module in modules: {
  parent: automationAccount
  name: module.name
  properties: {
    contentLink: {
      uri: module.version == 'latest' ? '${module.uri}/${module.name}' : '${module.uri}/${module.name}/${module.version}'
      version: module.version == 'latest' ? null : module.version
    }
  }
}]

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = [for runbook in runbooks: {
  parent: automationAccount
  name: runbook.runbookName
  location: location
  properties: {
    runbookType: runbook.runbookType
    logProgress: runbook.logProgress
    logVerbose: runbook.logVerbose
    publishContentLink: {
      uri: runbook.runbookUri
    }
  }
}]

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: automationAccount

  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

resource diagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = if (enableDiagnostics) {
  scope: automationAccount

  name: diagnosticsName
  properties: {
    workspaceId: resourceId(logAnalyticsSubscriptionId, logAnalyticsResourceGroup, 'Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)
    storageAccountId: resourceId(diagnosticStorageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', diagnosticStorageAccountName)
    logs: [
      {
        category: 'JobLogs'
        enabled: true
      }
      {
        category: 'JobStreams'
        enabled: true
      }
      {
        category: 'DscNodeStatus'
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

output systemIdentityPrincipalId string = automationAccount.identity.principalId
