@description('Name of the health model resource.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Resource ID of the Application Insights component to use for topology-based discovery.')
param applicationInsightsResourceId string

// --------------------------------------------------------------------------
// Health Model
// ---------------------------------------------------------------------------

resource healthModel 'Microsoft.CloudHealth/healthmodels@2026-05-01-preview' = {
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

resource authSetting 'Microsoft.CloudHealth/healthmodels/authenticationsettings@2026-05-01-preview' = {
  parent: healthModel
  name: 'default-auth'
  properties: {
    displayName: 'System-assigned identity'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

// ---------------------------------------------------------------------------
// Discovery Rule — Application Insights Topology
// ---------------------------------------------------------------------------
// Uses the application map from an Application Insights resource to discover
// the components of your application and their dependencies. Recommended
// signals are enabled so each discovered entity automatically receives
// curated health signals. Relationship discovery is enabled so the platform
// infers topology links between components.
// ---------------------------------------------------------------------------

resource discoveryRule 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-05-01-preview' = {
  parent: healthModel
  name: 'discover-app-topology'
  properties: {
    displayName: 'Discover Application Insights topology'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ApplicationInsightsTopology'
      applicationInsightsResourceId: applicationInsightsResourceId
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
