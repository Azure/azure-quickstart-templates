targetScope = 'resourceGroup'

@sealed()
type modelConfiguration = {
  @minLength(1)
  name: string
  @minLength(1)
  deploymentName: string
  @minLength(1)
  modelName: string
  @minLength(1)
  modelVersion: string
  @minValue(0)
  @maxValue(100)
  priority: int
  @minValue(1)
  @maxValue(100)
  weight: int
}

@sealed()
type backendConfiguration = {
  @minLength(2)
  @maxLength(64)
  accountName: string
  @minLength(1)
  aliasName: string
  @minLength(1)
  @maxLength(30)
  models: modelConfiguration[]
}

@description('Name of the Azure AI Gateway. Use lowercase letters, numbers, and hyphens, starting and ending with a letter or number.')
@minLength(3)
@maxLength(24)
param gatewayName string = 'aigateway-${uniqueString(resourceGroup().id)}'

@description('Location for the monitoring resources.')
param location string = resourceGroup().location

@description('An Azure region where your subscription has access to the Azure AI Gateway preview.')
param gatewayLocation string = location

@description('Optional existing Azure OpenAI account in this resource group, its deployed chat models, and a client-facing alias. Leave null to deploy the gateway without a backend.')
param backend backendConfiguration?

@description('Maximum tokens per identity per minute for requests using the model alias.')
@minValue(1)
param aliasTokenLimit int = 10000

@description('Deploy Application Insights and Log Analytics, and export gateway telemetry without request or response payloads.')
param enableMonitoring bool = false

@description('Tags to apply to the gateway and monitoring resources.')
param tags object = {}

var providerName = 'azure-openai'
var openAiUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')

resource azureOpenAi 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = if (backend != null) {
  name: backend!.accountName
}

resource gateway 'Microsoft.ApiManagement/aigateways@2025-09-01-preview' = {
  name: gatewayName
  location: gatewayLocation
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {}
}

// The gateway creates its default workspace.
resource workspace 'Microsoft.ApiManagement/aigateways/workspaces@2025-09-01-preview' existing = {
  parent: gateway
  name: 'default'
}

resource runtimeApiKey 'Microsoft.ApiManagement/aigateways/apiKeys@2025-09-01-preview' = {
  parent: gateway
  name: 'default'
  properties: {
    displayName: 'Default runtime key'
    state: 'active'
  }
}

resource openAiUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (backend != null) {
  scope: azureOpenAi
  name: guid(azureOpenAi!.id, gateway.id, openAiUserRoleId)
  properties: {
    roleDefinitionId: openAiUserRoleId
    principalId: gateway.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource modelProvider 'Microsoft.ApiManagement/aigateways/workspaces/modelProviders@2025-09-01-preview' = if (backend != null) {
  parent: workspace
  name: providerName
  dependsOn: [
    openAiUserRole
  ]
  properties: {
    type: 'azureOpenAi'
    endpointUri: azureOpenAi!.properties.endpoint
    credentials: {
      type: 'managedIdentity'
    }
  }
}

resource models 'Microsoft.ApiManagement/aigateways/workspaces/modelProviders/models@2025-09-01-preview' = [for model in (backend.?models ?? []): {
  parent: modelProvider
  name: model.name
  properties: {
    apiFormat: 'OpenAIChatCompletions'
    supportedEndpoints: [
      '/v1/chat/completions'
    ]
    deployment: {
      modelName: model.modelName
      name: model.deploymentName
      version: model.modelVersion
      format: 'OpenAI'
    }
  }
}]

resource modelAlias 'Microsoft.ApiManagement/aigateways/workspaces/aliases@2025-09-01-preview' = if (backend != null) {
  parent: workspace
  name: backend!.aliasName
  dependsOn: [
    models
  ]
  properties: {
    routes: [for model in backend!.models: {
      providerName: providerName
      modelName: model.name
      priority: model.priority
      weight: model.weight
    }]
    policies: [
      {
        type: 'tokenLimit'
        period: 'minute'
        count: aliasTokenLimit
        counterKey: [
          'identity'
        ]
      }
    ]
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (enableMonitoring) {
  name: '${gatewayName}-logs'
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (enableMonitoring) {
  name: '${gatewayName}-insights'
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource telemetryExporter 'Microsoft.ApiManagement/aigateways/workspaces/telemetryExporters@2025-09-01-preview' = if (enableMonitoring) {
  parent: workspace
  name: 'appinsights'
  properties: {
    kind: 'ApplicationInsights'
    payloadCapture: false
    applicationInsights: {
      connectionString: appInsights!.properties.ConnectionString
      resourceId: appInsights!.id
    }
  }
}

output gatewayId string = gateway.id
output gatewayPrincipalId string = gateway.identity.principalId
output workspaceId string = workspace.id
output runtimeApiKeyId string = runtimeApiKey.id
output modelAliasName string = backend != null ? backend!.aliasName : ''
output applicationInsightsId string = enableMonitoring ? appInsights.id : ''
