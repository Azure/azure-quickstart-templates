@description('Name of the health model. This also becomes the root entity name.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Resource ID of the Application Insights component to discover topology from.')
param applicationInsightsResourceId string

// Health Model
resource healthModel 'Microsoft.CloudHealth/healthmodels@2026-05-01-preview' = {
  name: healthModelName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// Authentication Setting
resource authSetting 'Microsoft.CloudHealth/healthmodels/authenticationsettings@2026-05-01-preview' = {
  parent: healthModel
  name: 'default-auth'
  properties: {
    displayName: 'Default Authentication'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

// Discovery Rule — discovers application topology from App Insights app map.
// Cloud roles and their dependency targets are created as entities.
// Relationships between roles and dependencies are discovered automatically.
resource appInsightsDiscovery 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-05-01-preview' = {
  parent: healthModel
  name: healthModelName
  properties: {
    displayName: 'Discover App Insights Topology'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ApplicationInsightsTopology'
      applicationInsightsResourceId: applicationInsightsResourceId
    }
  }
}

output healthModelName string = healthModel.name
output healthModelId string = healthModel.id
output healthModelPrincipalId string = healthModel.identity.principalId
output discoveryRuleName string = appInsightsDiscovery.name
