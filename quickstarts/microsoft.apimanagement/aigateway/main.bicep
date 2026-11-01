targetScope = 'resourceGroup'

@sealed()
type aliasRoute = {
  modelName: 'gpt-5.4' | 'gpt-5.3-codex' | 'gpt-5.4-mini'
  @minValue(0)
  @maxValue(100)
  priority: int
  @minValue(1)
  @maxValue(100)
  weight: int
}

@sealed()
type aliasConfiguration = {
  @minLength(1)
  name: string
  @minLength(1)
  @maxLength(30)
  routes: aliasRoute[]
}

@description('Name of the Azure AI Gateway. Use lowercase letters, numbers, and hyphens, starting and ending with a letter or number.')
@minLength(3)
@maxLength(24)
param gatewayName string = 'aigateway-${uniqueString(resourceGroup().id)}'

@description('Location for the Foundry account, model deployments, and monitoring resources. Select a region with capacity for all three models.')
param location string = resourceGroup().location

@description('An Azure region where your subscription has access to the Azure AI Gateway preview.')
param gatewayLocation string = location

@description('Name of the new Microsoft Foundry account and its custom subdomain.')
@minLength(2)
@maxLength(64)
param foundryAccountName string = 'aigateway-foundry-${uniqueString(resourceGroup().id)}'

@description('GlobalStandard capacity for each of the three Foundry model deployments. Ensure the subscription has quota for each model.')
@minValue(1)
param modelCapacity int = 10

@description('Client-facing aliases and routes. Lower priority values are preferred; weights select routes at the same priority.')
@minLength(1)
@maxLength(30)
param aliases aliasConfiguration[] = [
  {
    name: 'model-router'
    routes: [
      { modelName: 'gpt-5.4', priority: 0, weight: 100 }
      { modelName: 'gpt-5.3-codex', priority: 1, weight: 100 }
      { modelName: 'gpt-5.4-mini', priority: 2, weight: 100 }
    ]
  }
  {
    name: 'fast'
    routes: [
      { modelName: 'gpt-5.4-mini', priority: 0, weight: 100 }
    ]
  }
  {
    name: 'primary'
    routes: [
      { modelName: 'gpt-5.4', priority: 0, weight: 100 }
    ]
  }
]

@description('Deploy Application Insights and Log Analytics, and export gateway telemetry without request or response payloads.')
param enableMonitoring bool = false

@description('Tags to apply to the gateway, Foundry account, and monitoring resources.')
param tags object = {}

var providerName = 'foundry'
var openAiUserRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
)
var foundryModels = [
  {
    name: 'gpt-5.4'
    version: '2026-03-05'
    tokenLimitPerMinute: 200000
    monthlyCostLimitUsd: 5
  }
  {
    name: 'gpt-5.3-codex'
    version: '2026-02-24'
    tokenLimitPerMinute: 200000
    monthlyCostLimitUsd: 5
  }
  {
    name: 'gpt-5.4-mini'
    version: '2026-03-17'
    tokenLimitPerMinute: 400000
    monthlyCostLimitUsd: 5
  }
]

resource aiServices 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: foundryAccountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    allowProjectManagement: false
    customSubDomainName: toLower(foundryAccountName)
    disableLocalAuth: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

@batchSize(1)
resource foundryDeployments 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = [
  for model in foundryModels: {
    parent: aiServices
    name: model.name
    sku: {
      name: 'GlobalStandard'
      capacity: modelCapacity
    }
    properties: {
      model: {
        name: model.name
        version: model.version
        format: 'OpenAI'
      }
    }
  }
]

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

resource aiGatewayOpenAiUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aiServices
  name: guid(aiServices.id, gateway.id, openAiUserRoleId)
  properties: {
    roleDefinitionId: openAiUserRoleId
    principalId: gateway.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource foundryModelProvider 'Microsoft.ApiManagement/aigateways/workspaces/modelProviders@2025-09-01-preview' = {
  parent: workspace
  name: providerName
  dependsOn: [
    aiGatewayOpenAiUserRole
  ]
  properties: {
    displayName: 'Microsoft Foundry'
    type: 'azureOpenAi'
    endpointUri: 'https://${aiServices.name}.openai.azure.com/'
    credentials: {
      type: 'managedIdentity'
      managedIdentity: {
        resource: 'https://cognitiveservices.azure.com'
      }
    }
  }
}

resource models 'Microsoft.ApiManagement/aigateways/workspaces/modelProviders/models@2025-09-01-preview' = [
  for (model, i) in foundryModels: {
    parent: foundryModelProvider
    name: model.name
    dependsOn: [
      foundryDeployments[i]
    ]
    properties: {
      displayName: model.name
      apiFormat: 'OpenAIChatCompletions'
      supportedEndpoints: [
        '/v1/chat/completions'
        '/v1/responses'
      ]
      deployment: {
        modelName: model.name
        name: model.name
        version: model.version
        format: 'OpenAI'
      }
      policies: [
        {
          type: 'tokenLimit'
          period: 'minute'
          count: model.tokenLimitPerMinute
          counterKey: [
            'identity'
          ]
        }
        {
          type: 'costLimit'
          id: 'monthly-caller-budget'
          period: 'month'
          amount: model.monthlyCostLimitUsd
          counterKey: [
            'identity'
          ]
        }
        {
          type: 'contentSafety'
          hateSeverity: 'Medium'
          selfHarmSeverity: 'Medium'
          sexualSeverity: 'Medium'
          violenceSeverity: 'Medium'
        }
      ]
    }
  }
]

resource modelAliases 'Microsoft.ApiManagement/aigateways/workspaces/aliases@2025-09-01-preview' = [
  for alias in aliases: {
    parent: workspace
    name: alias.name
    dependsOn: [
      models
    ]
    properties: {
      routes: [
        for route in alias.routes: {
          providerName: providerName
          modelName: route.modelName
          priority: route.priority
          weight: route.weight
        }
      ]
    }
  }
]

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
  name: 'applicationInsights'
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
output foundryAccountId string = aiServices.id
output foundryModelDeploymentIds array = [for (model, i) in foundryModels: foundryDeployments[i].id]
output modelAliasNames array = [for alias in aliases: alias.name]
output applicationInsightsId string = enableMonitoring ? appInsights.id : ''
