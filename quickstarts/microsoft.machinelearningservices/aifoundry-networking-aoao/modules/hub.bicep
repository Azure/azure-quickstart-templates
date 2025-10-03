// Parameters
@description('Specifies the name')
param name string

@description('Specifies the location.')
param location string

@description('Specifies the resource tags.')
param tags object

@description('The SKU name to use for the AI Foundry Hub Resource')
param skuName string = 'Basic'

@description('The SKU tier to use for the AI Foundry Hub Resource')
@allowed(['Basic', 'Free', 'Premium', 'Standard'])
param skuTier string = 'Basic'

@description('Specifies the display name')
param friendlyName string = name

@description('Specifies the description')
param description_ string

@description('Specifies the Isolation mode for the managed network of a machine learning workspace.')
@allowed([
  'AllowInternetOutbound'
  'AllowOnlyApprovedOutbound'
  'Disabled'
])
param isolationMode string = 'AllowInternetOutbound'

@description('Specifies the public network access for the machine learning workspace.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Specifies the resource ID of the application insights resource for storing diagnostics logs')
param applicationInsightsId string

@description('Specifies the resource ID of the container registry resource for storing docker images')
param containerRegistryId string

@description('Specifies the resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Specifies the resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Specifies thename of the Azure AI Services resource')
param aiServicesName string

@description('Specifies the authentication method for the OpenAI Service connection.')
@allowed([
  'ApiKey'
  'AAD'
  'ManagedIdentity'
  'None'
])
param connectionAuthType string = 'AAD'

@description('Specifies the name for the Azure OpenAI Service connection.')
param aiServicesConnectionName string = ''

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the object id of a Miccrosoft Entra ID user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userObjectId string = ''

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'ComputeInstanceEvent'
])
param logsToEnable array = [
  'ComputeInstanceEvent'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param metricsToEnable array = [
  'AllMetrics'
]

@description('Determines whether or not to use credentials for the system datastores of the workspace workspaceblobstore and workspacefilestore. The default value is accessKey, in which case, the workspace will create the system datastores with credentials. If set to identity, the workspace will create the system datastores with no credentials.')
@allowed([
  'identity'
  'accessKey'
])
param systemDatastoresAuthMode string = 'identity'

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var logs = [
  for log in logsToEnable: {
    category: log
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]

var metrics = [
  for metric in metricsToEnable: {
    category: metric
    timeGrain: null
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]

// Resources
resource aiServices 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: aiServicesName
}

resource hub 'Microsoft.MachineLearningServices/workspaces@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: friendlyName
    description: description_
    managedNetwork: {
      isolationMode: isolationMode
    }
    publicNetworkAccess: publicNetworkAccess

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId == '' ? null : containerRegistryId
    systemDatastoresAuthMode: systemDatastoresAuthMode
  }

  resource aiServicesConnection 'connections@2024-01-01-preview' = {
    name: !empty(aiServicesConnectionName) ? aiServicesConnectionName : toLower('${aiServices.name}-connection')
    properties: {
      category: 'AIServices'
      target: aiServices.properties.endpoint
#disable-next-line BCP225
      authType: connectionAuthType
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServices.id
      }
      credentials: connectionAuthType == 'ApiKey'
        ? {
            key: aiServices.listKeys().key1
          }
        : null
    }
  }
}

resource azureMLDataScientistRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
  scope: subscription()
}

// This role assignment grants the user the required permissions to start a Prompt Flow in a compute service within Azure AI Foundry
resource azureMLDataScientistUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(hub.id, azureMLDataScientistRole.id, userObjectId)
  scope: hub
  properties: {
    roleDefinitionId: azureMLDataScientistRole.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: hub
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

// Outputs
output name string = hub.name
output id string = hub.id
