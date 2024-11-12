@minLength(1)
@maxLength(32)
@description('Name which is used to generate a short unique hash for each resource')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Location for the experiment resource')
param experimentWorkspaceLocation string = 'eastus2' // Currently Experiment Workspace only has presense in eastus2

@description('Id of the user or app to assign application roles')
param principalId string = '' // Entra object Id

@description('Type of the principal Id')
@allowed([
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
])
param principalType string = 'User'

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var prefix = '${name}-${resourceToken}'

// Create Log Analytics workspace, App Insights, Storage Account and Data Export Rule
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${prefix}-loganalytics'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${prefix}-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'storage${resourceToken}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: false
  }
}

resource dataExportRule 'Microsoft.OperationalInsights/workspaces/dataExports@2020-08-01' = {
  name: '${prefix}-dataexportrule'
  parent: logAnalytics
  properties: {
    destination: {
      resourceId: storageAccount.id
    }
    enable: true
    tableNames: [
      'AppEvents'
      'AppEvents_CL'
    ]
  }
}

// Create App Configuration Store
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-09-01-preview' = {
  name: '${prefix}-appconfig'
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    encryption: {}
    disableLocalAuth: true
    enablePurgeProtection: false
    experimentation:{}
    dataPlaneProxy:{
      authenticationMode: 'Pass-through'
      privateLinkDelegation: 'Disabled'
    }
    telemetry: {
      resourceId: applicationInsights.id
    }
  }
}

// Create Experiment Workspace with managed identity
resource expIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-id-exp'
  location: location
}

// Noite: no intellisense during private preview period
#disable-next-line BCP081
resource experimentWorkspace 'Microsoft.Experimentation/experimentWorkspaces@2024-11-30-preview' = {
  name: 'exp${resourceToken}'
  location: experimentWorkspaceLocation
  kind: 'Regular'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${expIdentity.id}': {} }
  }
  properties: {
    logAnalyticsWorkspaceResourceId: logAnalytics.id
    logsExporterStorageAccountResourceId: storageAccount.id
  }
}

// Allow experiment workspace read access to logs storage account
var storageDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' // Storage Blob Data Reader
resource storageAccountExpAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, principalId, storageDataReaderRoleId)
  scope: storageAccount
  properties: {
    principalId: expIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageDataReaderRoleId)
  }
}

// Allow experiment workspace read access to log analytics workspace
var logAnalyticsReaderRoleId = '73c42c96-874c-492b-b04d-ab87d138a893'  // Log Analytics Reader
resource logAnalyticsExpAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, principalId, logAnalyticsReaderRoleId)
  scope: logAnalytics
  properties: {
    principalId: expIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', logAnalyticsReaderRoleId)
  }
}

// Allow input principal read/write access to app configuration
var appConfigDataOwnerRoleId = '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b' // App Configuration Data Owner
resource appConfigAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId) && !empty(principalType)) {
  name: guid(subscription().id, resourceGroup().id, principalId, appConfigDataOwnerRoleId)
  scope: appConfig
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', appConfigDataOwnerRoleId)
  }
}
  
// Allow input principal read/write access to online experiment metrics
var experimentMetricsRoleId = '6188b7c9-7d01-4f99-a59f-c88b630326c0' // Experimentation metrics contributor
resource experimentWorkspaceAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId) && !empty(principalType)) {
  name: guid(subscription().id, resourceGroup().id, principalId, experimentMetricsRoleId)
  scope: experimentWorkspace
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', experimentMetricsRoleId)
  }
}

output AZURE_LOCATION string = location
output APPLICATIONINSIGHTS_CONNECTION_STRING string = applicationInsights.properties.ConnectionString
output APP_CONFIGURATION_ENDPOINT string = appConfig.properties.endpoint
output EXPERIMENT_WORKSPACE_ID string = experimentWorkspace.id
