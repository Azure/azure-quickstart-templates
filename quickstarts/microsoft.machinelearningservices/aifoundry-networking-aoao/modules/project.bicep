// Parameters
@description('Specifies the name')
param name string

@description('Specifies the location.')
param location string

@description('Specifies the resource tags.')
param tags object

@description('Specifies the display name')
param friendlyName string = name

@description('Specifies the public network access for the machine learning workspace.')
param publicNetworkAccess string = 'Enabled'

@description('Specifies the AI hub resource id')
param hubId string

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the object id of a Miccrosoft Entra ID user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userObjectId string = ''

@description('Specifies the principal id of the Azure AI Services.')
param aiServicesPrincipalId string = ''

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'AmlComputeClusterEvent'
  'AmlComputeClusterNodeEvent'
  'AmlComputeJobEvent'
  'AmlComputeCpuGpuUtilization'
  'AmlRunStatusChangedEvent'
  'ModelsChangeEvent'
  'ModelsReadEvent'
  'ModelsActionEvent'
  'DeploymentReadEvent'
  'DeploymentEventACI'
  'DeploymentEventAKS'
  'InferencingOperationAKS'
  'InferencingOperationACI'
  'EnvironmentChangeEvent'
  'EnvironmentReadEvent'
  'DataLabelChangeEvent'
  'DataLabelReadEvent'
  'DataSetChangeEvent'
  'DataSetReadEvent'
  'PipelineChangeEvent'
  'PipelineReadEvent'
  'RunEvent'
  'RunReadEvent'
])
param logsToEnable array = [
  'AmlComputeClusterEvent'
  'AmlComputeClusterNodeEvent'
  'AmlComputeJobEvent'
  'AmlComputeCpuGpuUtilization'
  'AmlRunStatusChangedEvent'
  'ModelsChangeEvent'
  'ModelsReadEvent'
  'ModelsActionEvent'
  'DeploymentReadEvent'
  'DeploymentEventACI'
  'DeploymentEventAKS'
  'InferencingOperationAKS'
  'InferencingOperationACI'
  'EnvironmentChangeEvent'
  'EnvironmentReadEvent'
  'DataLabelChangeEvent'
  'DataLabelReadEvent'
  'DataSetChangeEvent'
  'DataSetReadEvent'
  'PipelineChangeEvent'
  'PipelineReadEvent'
  'RunEvent'
  'RunReadEvent'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param metricsToEnable array = [
  'AllMetrics'
]

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
resource project 'Microsoft.MachineLearningServices/workspaces@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'Project'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: friendlyName
    hbiWorkspace: false
    v1LegacyMode: false
    publicNetworkAccess: publicNetworkAccess
    hubResourceId: hubId
    systemDatastoresAuthMode: 'identity'
  }
}

resource azureMLDataScientistRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
  scope: subscription()
}

// This role assignment grants the user the required permissions to start a Prompt Flow in a compute service within Azure AI Foundry
resource azureMLDataScientistUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(project.id, azureMLDataScientistRole.id, userObjectId)
  scope: project
  properties: {
    roleDefinitionId: azureMLDataScientistRole.id
    principalType: 'User'
    principalId: userObjectId
  }
}

// This role assignment grants the Azure AI Services managed identity the required permissions to start Prompt Flow in a compute service defined in Azure AI Foundry
resource azureMLDataScientistManagedIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(aiServicesPrincipalId)) {
  name: guid(project.id, azureMLDataScientistRole.id, aiServicesPrincipalId)
  scope: project
  properties: {
    roleDefinitionId: azureMLDataScientistRole.id
    principalType: 'ServicePrincipal'
    principalId: aiServicesPrincipalId
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: project
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

// Outputs
output name string = project.name
output id string = project.id
output principalId string = project.identity.principalId
