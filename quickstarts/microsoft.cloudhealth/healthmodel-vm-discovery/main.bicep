@description('Name of the health model. This also becomes the root entity name.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tag name used to identify resources for discovery.')
param tagName string = 'healthmodel'

@description('Tag value to match. Defaults to the health model name.')
param tagValue string = healthModelName

// Health Model
resource healthModel 'Microsoft.CloudHealth/healthmodels@2026-05-01-preview' = {
  name: healthModelName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// Authentication Setting — uses the health model's system-assigned managed identity
resource authSetting 'Microsoft.CloudHealth/healthmodels/authenticationsettings@2026-05-01-preview' = {
  parent: healthModel
  name: 'default-auth'
  properties: {
    displayName: 'Default Authentication'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

// Discovery Rule — discovers VMs by tag, adds recommended signals automatically.
// Named the same as the health model so discovered resources parent under the root entity.
resource discoveryRule 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-05-01-preview' = {
  parent: healthModel
  name: healthModelName
  properties: {
    displayName: 'Discover VMs'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: 'resources | where type =~ \'microsoft.compute/virtualmachines\' and tags[\'${tagName}\'] =~ \'${tagValue}\''
    }
  }
}

output healthModelName string = healthModel.name
output healthModelId string = healthModel.id
output location string = healthModel.location
