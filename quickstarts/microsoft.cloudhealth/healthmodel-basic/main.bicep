@description('Name of the health model resource.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Azure Resource Graph query that discovers the resources to monitor. The query must return a column named "id" containing resource IDs.')
param resourceGraphQuery string = 'resources | where type =~ "microsoft.compute/virtualMachines" | where resourceGroup =~ resourceGroup().name'

// --------------------------------------------------------------------------
// Health Model
// ---------------------------------------------------------------------------
// The health model is the top-level resource. A system-assigned managed
// identity is required so the discovery rule can query Azure Resource Graph.
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
// Discovery rules reference an authentication setting by name. This setting
// uses the health model's system-assigned managed identity.
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
// Discovers resources via an Azure Resource Graph query. Recommended signals
// and relationship discovery are both enabled, so the platform automatically
// attaches curated health signals and infers topology.
// ---------------------------------------------------------------------------

resource discoveryRule 'Microsoft.CloudHealth/healthModels/discoveryRules@2026-01-01-preview' = {
  parent: healthModel
  name: 'discover-target-resources'
  properties: {
    displayName: 'Discover target resources'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: resourceGraphQuery
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output healthModelId string = healthModel.id
output healthModelName string = healthModel.name
output healthModelPrincipalId string = healthModel.identity.principalId
output discoveryRuleName string = discoveryRule.name
