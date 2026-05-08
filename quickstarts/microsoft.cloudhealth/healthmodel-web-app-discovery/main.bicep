@description('Name of the health model. This also becomes the root entity name.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tag name used to identify resources for discovery. Defaults to workload.')
param tagName string = 'workload'

@description('Tag value to match. Defaults to my-web-app.')
param tagValue string = 'my-web-app'

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

// =============================================================================
// T1 Entities — logical tier groupings under the root
// (same structure as healthmodel-web-app)
// =============================================================================

resource frontendEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend'
  properties: {
    displayName: 'Frontend'
    canvasPosition: {
      x: 0
      y: 200
    }
  }
}

resource backendEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend'
  properties: {
    displayName: 'Backend'
    canvasPosition: {
      x: 450
      y: 200
    }
  }
}

resource dataEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'data'
  properties: {
    displayName: 'Data'
    canvasPosition: {
      x: 900
      y: 200
    }
  }
}

// T1 → Root relationships
resource rootToFrontend 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-frontend'
  properties: {
    parentEntityName: healthModelName
    childEntityName: frontendEntity.name
  }
}

resource rootToBackend 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-backend'
  properties: {
    parentEntityName: healthModelName
    childEntityName: backendEntity.name
  }
}

resource rootToData 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-data'
  properties: {
    parentEntityName: healthModelName
    childEntityName: dataEntity.name
  }
}

// =============================================================================
// Additional entities — represent things that discovery rules won't find.
// These are examples. Rename or replace them to fit your workload.
// After deployment, attach signals to them manually via the portal or API.
// =============================================================================
resource customEntity1 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'custom-entity-1'
  properties: {
    displayName: 'Custom Entity 1'
    canvasPosition: {
      x: 0
      y: 600
    }
  }
}

resource customEntity2 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'custom-entity-2'
  properties: {
    displayName: 'Custom Entity 2'
    canvasPosition: {
      x: 450
      y: 600
    }
  }
}

resource customEntity3 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'custom-entity-3'
  properties: {
    displayName: 'Custom Entity 3'
    canvasPosition: {
      x: 900
      y: 600
    }
  }
}

// Custom entity → Tier relationships
resource frontendToCustom1 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend-custom-entity-1'
  properties: {
    parentEntityName: frontendEntity.name
    childEntityName: customEntity1.name
  }
}

resource backendToCustom2 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend-custom-entity-2'
  properties: {
    parentEntityName: backendEntity.name
    childEntityName: customEntity2.name
  }
}

resource dataToCustom3 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'data-custom-entity-3'
  properties: {
    parentEntityName: dataEntity.name
    childEntityName: customEntity3.name
  }
}

// =============================================================================
// Discovery Rules — one per tier, reusing the tier entity as the anchor.
// Discovered resources appear alongside the additional entities above.
// Recommended signals are added to all discovered resources automatically.
// =============================================================================

resource frontendDiscovery 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend'
  properties: {
    displayName: 'Discover Frontend Web Apps'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: 'resources | where type =~ \'microsoft.web/sites\' and tags[\'${tagName}\'] =~ \'${tagValue}\''
    }
  }
}

resource backendDiscovery 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend'
  properties: {
    displayName: 'Discover Backend VMs'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: 'resources | where type =~ \'microsoft.compute/virtualmachines\' and tags[\'${tagName}\'] =~ \'${tagValue}\''
    }
  }
}

resource dataDiscovery 'Microsoft.CloudHealth/healthmodels/discoveryrules@2026-05-01-preview' = {
  parent: healthModel
  name: 'data'
  properties: {
    displayName: 'Discover Data Cosmos DB Accounts'
    authenticationSetting: authSetting.name
    discoverRelationships: 'Enabled'
    addRecommendedSignals: 'Enabled'
    specification: {
      kind: 'ResourceGraphQuery'
      resourceGraphQuery: 'resources | where type =~ \'microsoft.documentdb/databaseaccounts\' and tags[\'${tagName}\'] =~ \'${tagValue}\''
    }
  }
}

output healthModelName string = healthModel.name
output healthModelId string = healthModel.id
output location string = healthModel.location
