// Parameters
@description('Name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param name string = 'acr${uniqueString(resourceGroup().id)}'

@description('Enable admin user that have push / pull permission to the registry.')
param adminUserEnabled bool = false

@description('Specifies whether to allow public network access for the container registry.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Premium'

@description('Specifies whether or not registry-wide pull is enabled from unauthenticated clients.')
param anonymousPullEnabled bool = false

@description('Specifies whether or not a single data endpoint is enabled per region for serving data.')
param dataEndpointEnabled bool = false

@description('Specifies the network rule set for the container registry.')
param networkRuleSet object = {
  defaultAction: 'Deny'
}

@description('Specifies ehether to allow trusted Azure services to access a network restricted registry.')
@allowed([
  'AzureServices'
  'None'
])
param networkRuleBypassOptions string = 'AzureServices'

@description('Specifies whether or not zone redundancy is enabled for this container registry.')
@allowed([
  'Disabled'
  'Enabled'
])
param zoneRedundancy string = 'Disabled'

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var logCategories = [
  'ContainerRegistryRepositoryEvents'
  'ContainerRegistryLoginEvents'
]
var metricCategories = [
  'AllMetrics'
]
var logs = [
  for category in logCategories: {
    category: category
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]
var metrics = [
  for category in metricCategories: {
    category: category
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]

// Resources
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
    dataEndpointEnabled: dataEndpointEnabled
    networkRuleBypassOptions: networkRuleBypassOptions
    networkRuleSet: networkRuleSet
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 7
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: containerRegistry
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

// Outputs
output id string = containerRegistry.id
output name string = containerRegistry.name
output sku string = containerRegistry.sku.name
