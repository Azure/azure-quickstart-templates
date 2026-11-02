targetScope = 'resourceGroup'

@description('How Microsoft Foundry models are configured: create a new Foundry account and model deployments, attach an existing Foundry account in this resource group, or skip model configuration for a later CLI/portal step.')
type foundryModeType = 'create' | 'existing' | 'none'

@description('Whether to skip MCP tool servers (none) or register the public Microsoft Learn MCP tool server with no authentication (create).')
type mcpModeType = 'none' | 'create'

@sealed()
type foundryModelConfiguration = {
  @minLength(1)
  name: string
  @minLength(1)
  version: string
  @minValue(1)
  tokenLimitPerMinute: int
  @minValue(1)
  monthlyCostLimitUsd: int
}

@sealed()
type aliasRoute = {
  @minLength(1)
  modelName: string
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

@description('Location for the Foundry account, model deployments, and monitoring resources. Select a region with capacity for the configured models.')
param location string = resourceGroup().location

@description('An Azure region where your subscription has access to the Azure AI Gateway preview.')
param gatewayLocation string = location

@description('Whether to create a new Foundry account and model deployments (create), attach an existing Foundry account in this resource group (existing), or deploy only the gateway and configure models later (none).')
param foundryMode foundryModeType = 'create'

@description('Name of the new or existing Microsoft Foundry account.')
@minLength(2)
@maxLength(64)
param foundryAccountName string = 'aigateway-foundry-${uniqueString(resourceGroup().id)}'

@description('GlobalStandard capacity for each Foundry model deployment when foundryMode is create.')
@minValue(1)
param modelCapacity int = 10

@description('Foundry models to deploy (when foundryMode is create) and register in the gateway catalog (when foundryMode is create or existing).')
param foundryModels foundryModelConfiguration[] = [
  {
    name: 'gpt-6.1-sol'
    version: '2026-09-29'
    tokenLimitPerMinute: 200000
    monthlyCostLimitUsd: 5
  }
  {
    name: 'gpt-5-mini'
    version: '2025-08-07'
    tokenLimitPerMinute: 400000
    monthlyCostLimitUsd: 5
  }
]

@description('Client-facing aliases and routes registered when foundryMode is create or existing. Lower priority values are preferred; weights select routes at the same priority.')
param aliases aliasConfiguration[] = [
  {
    name: 'gpt-latest'
    routes: [
      { modelName: 'gpt-6.1-sol', priority: 0, weight: 100 }
      { modelName: 'gpt-5-mini', priority: 1, weight: 100 }
    ]
  }
  {
    name: 'gpt-mini-latest'
    routes: [
      { modelName: 'gpt-5-mini', priority: 0, weight: 100 }
    ]
  }
]

@description('Deploy Application Insights and Log Analytics, and export gateway telemetry without request or response payloads.')
param enableMonitoring bool = false

@description('Skip MCP tool configuration by default (none), or create the no-auth Microsoft Learn MCP tool server (create).')
param mcpMode mcpModeType = 'none'

@description('Optional resource ID of an existing subnet in the same subscription and region, delegated to Microsoft.App/environments, for outbound VNet integration.')
param backendSubnetResourceId string = ''

@description('Optional CIDR ranges allowed to call registered models and MCP tool servers via an inline ipFilter policy. Leave empty to allow all caller IPs.')
param allowedCallerCidrRanges string[] = []

@description('Optional principal ID (for example, a Microsoft Foundry project managed identity or caller service principal) to grant the AI Gateway User role on the gateway.')
param gatewayUserPrincipalId string = ''

@description('Tags to apply to the gateway, Foundry account, and monitoring resources.')
param tags object = {}

var providerName = 'foundry'
var createFoundry = foundryMode == 'create'
var useExistingFoundry = foundryMode == 'existing'
var configureFoundryProvider = foundryMode != 'none'
var createLearnMcp = mcpMode == 'create'
var effectiveFoundryResourceId = createFoundry
  ? aiServices.id
  : (useExistingFoundry ? existingAiServices.id : '')
var optionalIpFilterPolicies = empty(allowedCallerCidrRanges)
  ? []
  : [
      {
        type: 'ipFilter'
        action: 'Allow'
        cidrRanges: allowedCallerCidrRanges
      }
    ]
var aiUserRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '53ca6127-db72-4b80-b1b0-d745d6d5456d'
)
var aiGatewayUserRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'caad7a21-134e-43f4-a550-c5ffc17e051c'
)
var monitoringMetricsPublisherRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '3913510d-42f4-4e42-8a64-420c390055eb'
)

resource aiServices 'Microsoft.CognitiveServices/accounts@2025-06-01' = if (createFoundry) {
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

resource existingAiServices 'Microsoft.CognitiveServices/accounts@2025-06-01' existing = if (useExistingFoundry) {
  name: foundryAccountName
}

@batchSize(1)
resource foundryDeployments 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = [
  for model in (createFoundry ? foundryModels : []): {
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
  properties: empty(backendSubnetResourceId)
    ? {}
    : {
        backend: {
          subnet: {
            id: backendSubnetResourceId
          }
        }
      }
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
  }
}

resource gatewayCallerUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(gatewayUserPrincipalId)) {
  scope: gateway
  name: guid(gateway.id, gatewayUserPrincipalId, aiGatewayUserRoleId)
  properties: {
    roleDefinitionId: aiGatewayUserRoleId
    principalId: gatewayUserPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource newFoundryAiUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (createFoundry) {
  scope: aiServices
  name: guid(resourceGroup().id, foundryAccountName, gateway.id, aiUserRoleId, 'create')
  properties: {
    roleDefinitionId: aiUserRoleId
    principalId: gateway.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource existingFoundryAiUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (useExistingFoundry) {
  scope: existingAiServices
  name: guid(resourceGroup().id, foundryAccountName, gateway.id, aiUserRoleId, 'existing')
  properties: {
    roleDefinitionId: aiUserRoleId
    principalId: gateway.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource foundryModelProvider 'Microsoft.ApiManagement/aigateways/workspaces/modelProviders@2025-09-01-preview' = if (configureFoundryProvider) {
  parent: workspace
  name: providerName
  dependsOn: [
    newFoundryAiUserRole
    existingFoundryAiUserRole
  ]
  properties: {
    kind: 'Foundry'
    displayName: 'Microsoft Foundry'
    foundry: {
      endpoint: 'https://${toLower(foundryAccountName)}.services.ai.azure.com/'
      resourceIds: [
        effectiveFoundryResourceId
      ]
      authentication: {
        kind: 'ManagedIdentity'
        managedIdentity: {
          resource: 'https://cognitiveservices.azure.com/'
        }
      }
    }
  }
}

resource models 'Microsoft.ApiManagement/aigateways/workspaces/modelProviders/models@2025-09-01-preview' = [
  for model in (configureFoundryProvider ? foundryModels : []): {
    parent: foundryModelProvider
    name: model.name
    dependsOn: [
      foundryDeployments
    ]
    properties: {
      displayName: model.name
      apiFormat: 'OpenAIChatCompletions'
      supportedEndpoints: [
        '/openai/v1/chat/completions'
        '/openai/v1/responses'
      ]
      deployment: {
        resourceId: '${effectiveFoundryResourceId}/deployments/${model.name}'
        modelName: model.name
        modelVersion: model.version
      }
      policies: concat(
        [
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
        ],
        optionalIpFilterPolicies
      )
    }
  }
]

resource modelAliases 'Microsoft.ApiManagement/aigateways/workspaces/aliases@2025-09-01-preview' = [
  for alias in (configureFoundryProvider ? aliases : []): {
    parent: workspace
    name: alias.name
    dependsOn: [
      models
    ]
    properties: {
      aliasName: alias.name
      backendModels: [
        for route in alias.routes: {
          resourceId: resourceId(
            'Microsoft.ApiManagement/aigateways/workspaces/modelProviders/models',
            gatewayName,
            'default',
            providerName,
            route.modelName
          )
          priority: route.priority
          weight: route.weight
        }
      ]
    }
  }
]

resource learnMcpToolServer 'Microsoft.ApiManagement/aigateways/workspaces/toolServers@2025-09-01-preview' = if (createLearnMcp) {
  parent: workspace
  name: 'learn'
  properties: {
    displayName: 'Microsoft Learn MCP'
    description: 'Public Microsoft Learn documentation MCP server (no authentication).'
    type: 'mcp'
    failureMode: 'failClosed'
    accessState: 'active'
    subscriptionRequired: true
    policies: optionalIpFilterPolicies
    endpoints: [
      {
        id: 'learn'
        namespace: 'learn'
        kind: 'mcp'
        required: false
        credentials: {
          type: 'noAuth'
        }
        mcp: {
          transport: 'streamableHttp'
          url: 'https://learn.microsoft.com/api/mcp'
        }
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
    #disable-next-line BCP037
    AzureMonitorWorkspaceIngestionMode: 'Enabled'
  }
}

resource appInsightsMetricsPublisherRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableMonitoring) {
  scope: appInsights
  name: guid(resourceGroup().id, gateway.id, monitoringMetricsPublisherRoleId, 'insights')
  properties: {
    roleDefinitionId: monitoringMetricsPublisherRoleId
    principalId: gateway.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource telemetryExporter 'Microsoft.ApiManagement/aigateways/workspaces/telemetryExporters@2025-09-01-preview' = if (enableMonitoring) {
  parent: workspace
  name: 'applicationInsights'
  dependsOn: [
    appInsightsMetricsPublisherRole
  ]
  properties: {
    kind: 'OpenTelemetry'
    payloadCapture: false
    applicationInsights: {
      resourceId: appInsights!.id
    }
    openTelemetry: {
      #disable-next-line BCP053
      metricsEndpoint: appInsights!.properties.?OTLPMetricsEndpoint ?? appInsights!.properties.?MetricsIngestionEndpoint
      #disable-next-line BCP053
      logsEndpoint: appInsights!.properties.?OTLPLogsEndpoint ?? appInsights!.properties.?LogsIngestionEndpoint
      #disable-next-line BCP053
      tracesEndpoint: appInsights!.properties.?OTLPTracesEndpoint ?? appInsights!.properties.?TracesIngestionEndpoint
      credentials: {
        managedIdentity: {
          resource: 'https://monitor.azure.com'
        }
      }
    }
  }
}

output gatewayId string = gateway.id
output gatewayPrincipalId string = gateway.identity.principalId
output workspaceId string = workspace.id
output runtimeApiKeyId string = runtimeApiKey.id
output foundryAccountId string = createFoundry
  ? aiServices.id
  : (useExistingFoundry ? existingAiServices.id : '')
output modelAliasNames array = [for alias in (configureFoundryProvider ? aliases : []): alias.name]
output learnMcpToolServerId string = createLearnMcp ? learnMcpToolServer.id : ''
output applicationInsightsId string = enableMonitoring ? appInsights.id : ''
#disable-next-line BCP053
output applicationInsightsDcrId string = enableMonitoring ? (appInsights!.properties.?DataCollectionRuleResourceId ?? appInsights!.properties.?DefaultDataCollectionRuleResourceId ?? '') : ''
