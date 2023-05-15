@minLength(5)
@maxLength(50)
@description('Azure Container Registry name')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Azure Container Registry location')
param location string = resourceGroup().location

@description('Azure Container Registry tier')
@allowed([
  'Basic'
  'Standard'
  'Premium'
  'Classic'
])
param acrSku string = 'Basic'

@description('Enable System Assign Identity for Azure Container Registry')
param enableSystemIdentity bool = false

@description('The list of user identity resource ids to associate with the Azure Container Registry')
@metadata({
  userAssignedIdentityResourceId: {}
})
param userAssignedIdentities object = {}

@description('Enable admin user')
param enableAdminUser bool = false

@description('Enable public network access')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Enable zone redundancy')
@allowed([
  'Disabled'
  'Enabled'
])
param zoneRedundancy string = 'Disabled'

@description('The network rule set for a container registry')
@metadata({
  defaultAction: 'The default action of allow or deny when no other rules match. Valid values are Allow/Deny'
  ipRules: [
    {
      action: 'Allow'
      value: 'Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed'
    }
  ]
})
param ipRules object = {}

@description('Allow trusted Azure services to access a network restricted registry')
@allowed([
  'AzureServices'
  'None'
])
param networkRuleBypassOptions string = 'None'

@description('Azure Container Registry policies')
@metadata({
  exportPolicy: {
    status: 'The value that indicates whether the policy is enabled or not. Valid values are enabled/disabled'
  }
  quarantinePolicy: {
    status: 'The value that indicates whether the policy is enabled or not. Valid values are enabled/disabled'
  }
  retentionPolicy: {
    status: 'The value that indicates whether the policy is enabled or not. Valid values are enabled/disabled'
    days: 'The number of days to retain an untagged manifest after which it gets purged'
  }
  trustPolicy: {
    status: 'The value that indicates whether the policy is enabled or not. Valid values are enabled/disabled'
  }
})
param policies object = {}

@description('Enable delete lock')
param enableDeleteLock bool = false

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param logAnalyticsWorkspaceId string = ''

var lockName = '${acr.name}-lck'
var diagnosticsName = '${acr.name}-dgs'

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  identity: enableSystemIdentity ? {
    type: 'SystemAssigned'
  } : !empty(userAssignedIdentities) ? {
    type: 'UserAssigned'
    userAssignedIdentities: userAssignedIdentities
  } : null
  properties: {
    adminUserEnabled: enableAdminUser
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
    networkRuleBypassOptions: networkRuleBypassOptions
    networkRuleSet: !empty(ipRules) ? {
      defaultAction: ipRules.defaultAction
      ipRules: ipRules.ipRules
    } : {}
    policies: policies
  }
}

resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: acr
  name: diagnosticsName
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryLoginEvents'
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

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (enableDeleteLock) {
  scope: acr
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output name string = acr.name
output id string = acr.id
output acrLoginServer string = acr.properties.loginServer
