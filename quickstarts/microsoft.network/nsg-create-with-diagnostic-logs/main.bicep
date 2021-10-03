@description('Network security group name')
param nsgName string = uniqueString(resourceGroup().id)

@description('Network security group location')
param location string = resourceGroup().location

@description('Security rules')
@metadata({
  name: 'Rule name'
  properties: {
    access: 'Whether network traffic is allowed or denied'
    description: 'A description for the rule'
    destinationAddressPrefix: 'The destination address prefix. CIDR or destination IP range. Service Tags or * can also be used'
    destinationAddressPrefixes: [
      'The destination address prefixes. CIDR or destination IP ranges. Only used when destinationAddressPrefix is not specified'
    ]
    destinationApplicationSecurityGroups: [
      {
        id: 'Resource Id of destination application security group. Only used when destinationAddressPrefix/destinationAddressPrefixes is not specified'
      }
    ]
    destinationPortRange: 'The destination port or range'
    destinationPortRanges: [
      'The destination port ranges. Only used when destinationPortRange is not specified'
    ]
    direction: 'The direction of the rule. Inbound or Outbound'
    priority: 'The priority of the rule. The value can be between 100 and 4096'
    protocol: 'Network protocol for this rule'
    sourceAddressPrefix: 'The source address prefix. CIDR or source IP range. Service Tags or * can also be used'
    sourceAddressPrefixes: [
      'The source address prefixes. CIDR or source IP ranges. Only used when sourceAddressPrefix is not specified'
    ]
    sourceApplicationSecurityGroups: [
      {
        id: 'Resource Id of source application security group. Only used when sourceAddressPrefix/sourceAddressPrefixes is not specified'
      }
    ]
    sourcePortRange: 'The source port or range'
    sourcePortRanges: [
      'The source port ranges. Only used when sourcePortRange is not specified'
    ]
  }
})
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
