@description('Network security group name')
param nsgName string = uniqueString(resourceGroup().id)

@description('Network security group location')
param location string = resourceGroup().location

@description('Array containing security rules. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?tabs=bicep#securityrulepropertiesformat')
param securityRules array = []

@description('Enable delete lock')
param enableDeleteLock bool = false

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param logAnalyticsWorkspaceId string = ''

var lockName = '${nsg.name}-lck'
var diagnosticsName = '${nsg.name}-dgs'

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: rule.properties
    }]
  }
}

resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: nsg
  name: diagnosticsName
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: nsg
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output name string = nsg.name
output id string = nsg.id
