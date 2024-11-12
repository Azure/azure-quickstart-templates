targetScope = 'subscription'

@minLength(1)
@maxLength(64)
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

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
}

// Provision Log Analytics workspace, App Insights, with data export to storage account
module logAnalyticsWorkspace 'modules/loganalytics.bicep' = {
  name: 'loganalytics'
  scope: resourceGroup
  params: {
    name: '${prefix}-loganalytics'
    location: location
  }
}

module appInsights 'modules/appinsights.bicep' = {
  name: 'appinsights'
  scope: resourceGroup
  params: {
    name: '${prefix}-appinsights'
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    location: location
  }
}

module storageAccount 'modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    location: location
    storageAccountName: '${resourceToken}storage'
    storageAccountType: 'Standard_LRS'
  }
}

module dataExportRule 'modules/dataexport.bicep' = {
  name: 'loganalytics-dataexportrule'
  scope: resourceGroup
  params: {
    name: '${prefix}-dataexportrule'
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    storageAccountName: storageAccount.outputs.storageAccountName
    tables: [
      'AppEvents'
      'AppEvents_CL'
    ]
  }
}

// Provision App Configuration store linking to App Insights
module appConfig 'modules/appconfig.bicep' = {
  name: 'appconfig'
  scope: resourceGroup
  params: {
    location: location
    name: '${prefix}-appconfig'
    appInsightsId: appInsights.outputs.appInsightsId
  }
}

// Provision Experiment Workspace linking to Log Analytics workspace and Storage Account
module experimentWorkspace 'modules/experimentworkspace.bicep' = {
  name: 'experimentworkspace'
  scope: resourceGroup
  params: {
    name: 'exp${substring(resourceToken, 0, 10)}'
    location: experimentWorkspaceLocation
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    storageAccountName: storageAccount.outputs.storageAccountName
    identityName: '${prefix}-id-exp'
  }
}  

// Allow experiment workspace read access to storage
module logAnalyticsExpAccess 'modules/role.bicep' = {
  scope: resourceGroup
  name: 'storage-account-exp-role'
  params: {
    principalId: experimentWorkspace.outputs.expWorkspaceIdentityPrincipalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' // Storage Blob Data Reader
    principalType: 'ServicePrincipal'
  }
}

// Allow experiment workspace read access to log analytics workspace
module storageAccountExpAccess 'modules/role.bicep' = {
  scope: resourceGroup
  name: 'loganalytics-exp-role'
  params: {
    principalId: experimentWorkspace.outputs.expWorkspaceIdentityPrincipalId
    roleDefinitionId: '73c42c96-874c-492b-b04d-ab87d138a893' // Log Analytics Reader
    principalType: 'ServicePrincipal'
  }
}

// Allow input principal to read/write to app configuration
module appConfigDataAccess 'modules/role.bicep'  = if (!empty(principalId) && !empty(principalType)) {
  scope: resourceGroup
  name: 'appconfig-dataowner-role'
  params: {
    principalId: principalId
    roleDefinitionId: '6188b7c9-7d01-4f99-a59f-c88b630326c0' // App Configuration Data Owner
    principalType: principalType
  }
}
  
// Allow input principal to read/write to online experiment metrics
module experimentWorkspaceMetricAccess 'modules/role.bicep'  = if (!empty(principalId) && !empty(principalType)) {
  scope: resourceGroup
  name: 'experimentworkspace-metrics-role'
  params: {
    principalId: principalId
    roleDefinitionId: '6188b7c9-7d01-4f99-a59f-c88b630326c0' // Experimentation metric contributor
    principalType: principalType
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId

output APPLICATIONINSIGHTS_CONNECTION_STRING string = appInsights.outputs.appInsightsConnectionString
output APP_CONFIGURATION_ENDPOINT string = appConfig.outputs.endpoint
output EXPERIMENT_WORKSPACE_ID string = experimentWorkspace.outputs.expWorkspaceId
