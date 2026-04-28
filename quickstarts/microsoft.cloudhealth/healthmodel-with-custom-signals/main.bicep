@description('Name of the health model resource.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Azure Resource Graph query that discovers the resources to monitor. The query must return a column named "id" containing resource IDs.')
param resourceGraphQuery string = 'resources | where type =~ "microsoft.compute/virtualMachines" | where resourceGroup =~ resourceGroup().name'

@description('Whether the discovery rule should automatically add recommended signals to discovered entities.')
@allowed([
  'Enabled'
  'Disabled'
])
param addRecommendedSignals string = 'Enabled'

@description('Whether the discovery rule should automatically discover relationships between entities.')
@allowed([
  'Enabled'
  'Disabled'
])
param discoverRelationships string = 'Enabled'

@description('CPU utilization threshold (%) that marks a resource as unhealthy.')
@minValue(1)
@maxValue(100)
param cpuUnhealthyThreshold int = 90

@description('CPU utilization threshold (%) that marks a resource as degraded.')
@minValue(1)
@maxValue(100)
param cpuDegradedThreshold int = 75

// --------------------------------------------------------------------------
// Health Model
// ---------------------------------------------------------------------------
// The health model is the top-level resource that aggregates discovery rules,
// signal definitions, entities and relationships to provide a unified health
// view of your workload.
// ---------------------------------------------------------------------------

resource healthModel 'Microsoft.CloudHealth/healthModels@2026-01-01-preview' = {
  name: healthModelName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// ---------------------------------------------------------------------------
// Authentication Setting
// ---------------------------------------------------------------------------
// An authentication setting tells the health model which managed identity to
// use when querying Azure Resource Graph and accessing monitored resources.
// Discovery rules reference an authentication setting by name.
// ---------------------------------------------------------------------------

resource authSetting 'Microsoft.CloudHealth/healthModels/authenticationSettings@2026-01-01-preview' = {
  parent: healthModel
  name: 'default-auth'
  properties: {
    displayName: 'System-assigned identity'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

// ---------------------------------------------------------------------------
// Discovery Rule
// ---------------------------------------------------------------------------
// Discovery rules automatically detect Azure resources that should be part of
// the health model. They use an Azure Resource Graph query to find matching
// resources. When addRecommendedSignals is Enabled, the platform automatically
// attaches curated health signals to each discovered entity. When
// discoverRelationships is Enabled, the platform infers parent/child
// relationships between entities using built-in topology rules.
// ---------------------------------------------------------------------------

resource discoveryRule 'Microsoft.CloudHealth/healthModels/discoveryRules@2026-01-01-preview' = {
  parent: healthModel
  name: 'discover-target-resources'
  properties: {
    displayName: 'Discover target resources'
    authenticationSetting: authSetting.name
    discoverRelationships: discoverRelationships
    addRecommendedSignals: addRecommendedSignals
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: resourceGraphQuery
    }
  }
}

// ---------------------------------------------------------------------------
// Signal Definition (custom)
// ---------------------------------------------------------------------------
// In addition to the recommended signals added automatically by the discovery
// rule, you can define custom signal definitions. This example creates a CPU
// utilization signal with degraded and unhealthy thresholds evaluated against
// an Azure platform metric.
// ---------------------------------------------------------------------------

resource cpuSignal 'Microsoft.CloudHealth/healthModels/signalDefinitions@2026-01-01-preview' = {
  parent: healthModel
  name: 'custom-cpu-utilization'
  properties: {
    displayName: 'Custom CPU utilization'
    signalKind: 'AzureResourceMetric'
    metricNamespace: 'microsoft.compute/virtualMachines'
    metricName: 'Percentage CPU'
    aggregationType: 'Average'
    timeGrain: 'PT5M'
    refreshInterval: 'PT5M'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: cpuDegradedThreshold
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: cpuUnhealthyThreshold
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output healthModelId string = healthModel.id
output healthModelName string = healthModel.name
output healthModelPrincipalId string = healthModel.identity.principalId
output authenticationSettingName string = authSetting.name
output discoveryRuleName string = discoveryRule.name
output cpuSignalName string = cpuSignal.name
