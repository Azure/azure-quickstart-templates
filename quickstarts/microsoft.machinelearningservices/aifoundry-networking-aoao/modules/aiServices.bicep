// Parameters
@description('Specifies the name of the Azure AI Services account.')
param name string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource model definition representing SKU.')
param sku object = {
  name: 'S0'
}

@description('Specifies the identity of the aiServices resource.')
param identity object = {
  type: 'SystemAssigned'
}

@description('Specifies the resource tags.')
param tags object

@description('Specifies an optional subdomain name used for token-based authentication.')
param customSubDomainName string = ''

@description('Specifies whether disable the local authentication via API key.')
param disableLocalAuth bool = true

@description('Specifies whether or not public endpoint access is allowed for this account..')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Specifies the OpenAI deployments to create.')
param deployments array = []

@description('Specifies the workspace id of the Log Analytics used to monitor the Application Gateway.')
param workspaceId string

@description('Specifies the object id of a Miccrosoft Entra ID user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userObjectId string = ''

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var aiServicesLogCategories = [
  'Audit'
  'RequestResponse'
  'Trace'
]
var aiServicesMetricCategories = [
  'AllMetrics'
]
var aiServicesLogs = [
  for category in aiServicesLogCategories: {
    category: category
    enabled: true
  }
]
var aiServicesMetrics = [
  for category in aiServicesMetricCategories: {
    category: category
    enabled: true
  }
]

// Resources
resource aiServices 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: name
  location: location
  sku: sku
  kind: 'AIServices'
  identity: identity
  tags: tags
  properties: {
    customSubDomainName: customSubDomainName
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: publicNetworkAccess
  }
}

@batchSize(1)
resource model 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [
  for deployment in deployments: {
    name: deployment.model.name
    parent: aiServices
    sku: {
      capacity: deployment.sku.capacity ?? 100
      name: empty(deployment.sku.name) ? 'Standard' : deployment.sku.name
    }
    properties: {
      model: {
        format: 'OpenAI'
        name: deployment.model.name
        version: deployment.model.version
      }
    }
  }
]

resource cognitiveServicesContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
  scope: subscription()
}

// This role assignment grants the user the required permissions to eventually delete and purge the Azure AI Services account
resource cognitiveServicesContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(aiServices.id, cognitiveServicesContributorRoleDefinition.id, userObjectId)
  scope: aiServices
  properties: {
    roleDefinitionId: cognitiveServicesContributorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource cognitiveServicesUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
  scope: subscription()
}

// This role assignment grants the Azure AI Services managed identity the required permissions to access the AI services such as Azure OpenAI. 
resource cognitiveServicesUserIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiServices.id, cognitiveServicesUserRoleDefinition.id, 'aiServices')
  scope: aiServices
  properties: {
    roleDefinitionId: cognitiveServicesUserRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: aiServices.identity.principalId
  }
}

// This role assignment grants the user the Cognitive Services User role on the Azure AI Services account
resource cognitiveServicesUserUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(aiServices.id, cognitiveServicesUserRoleDefinition.id, userObjectId)
  scope: aiServices
  properties: {
    roleDefinitionId: cognitiveServicesUserRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource aiServicesDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: aiServices
  properties: {
    workspaceId: workspaceId
    logs: aiServicesLogs
    metrics: aiServicesMetrics
  }
}

// Outputs
output id string = aiServices.id
output name string = aiServices.name
output endpoint string = aiServices.properties.endpoint
output openAiEndpoint string = aiServices.properties.endpoints['OpenAI Language Model Instance API']
output principalId string = aiServices.identity.principalId
