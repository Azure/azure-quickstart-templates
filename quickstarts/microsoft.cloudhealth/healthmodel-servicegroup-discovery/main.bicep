@description('Name of the health model. This also becomes the root entity name.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Resource ID of the Service Group to discover resources from. Must be a full path, for example: /providers/Microsoft.Management/serviceGroups/myServiceGroup')
param serviceGroupId string

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

// Discovery Rule — discovers all resources in the specified Service Group.
// The backend detects this query pattern and performs recursive Service Group
// discovery server-side (up to 10 levels deep).
// Named the same as the health model because the backend automatically creates
// the Service Group as a grouping entity under root — no manual entity needed.
resource serviceGroupDiscovery 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-05-01-preview' = {
  parent: healthModel
  name: healthModelName
  properties: {
    displayName: 'Discover Service Group Resources'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: 'relationshipresources | where type =~ \'microsoft.relationships/servicegroupmember\' | where tostring(properties.TargetId) =~ \'${serviceGroupId}\' | project id=tostring(properties.SourceId)'
    }
  }
}

output healthModelName string = healthModel.name
output healthModelId string = healthModel.id
output location string = healthModel.location
