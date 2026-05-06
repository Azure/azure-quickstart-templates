@description('Name of the health model. This also becomes the root entity name.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

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

// T1 Entities — logical groupings under the root
resource frontendEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend'
  properties: {
    displayName: 'Frontend'
  }
}

resource backendEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend'
  properties: {
    displayName: 'Backend'
  }
}

resource dataEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'data'
  properties: {
    displayName: 'Data'
  }
}

// T2 Entities — components within each logical grouping
resource webEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'web'
  properties: {
    displayName: 'Web'
  }
}

resource apiGatewayEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'api-gateway'
  properties: {
    displayName: 'API Gateway'
  }
}

resource apiEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'api'
  properties: {
    displayName: 'API'
  }
}

resource workerEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'worker'
  properties: {
    displayName: 'Worker'
  }
}

resource databaseEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'database'
  properties: {
    displayName: 'Database'
  }
}

resource cacheEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'cache'
  properties: {
    displayName: 'Cache'
  }
}

// T1 → Root relationships (root entity is auto-created with the health model name)
resource rootToFrontend 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-frontend'
  properties: {
    parentEntityName: healthModelName
    childEntityName: 'frontend'
  }
  dependsOn: [frontendEntity]
}

resource rootToBackend 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-backend'
  properties: {
    parentEntityName: healthModelName
    childEntityName: 'backend'
  }
  dependsOn: [backendEntity]
}

resource rootToData 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-data'
  properties: {
    parentEntityName: healthModelName
    childEntityName: 'data'
  }
  dependsOn: [dataEntity]
}

// T2 → T1 relationships
resource frontendToWeb 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend-web'
  properties: {
    parentEntityName: 'frontend'
    childEntityName: 'web'
  }
  dependsOn: [frontendEntity, webEntity]
}

resource frontendToApiGateway 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend-api-gateway'
  properties: {
    parentEntityName: 'frontend'
    childEntityName: 'api-gateway'
  }
  dependsOn: [frontendEntity, apiGatewayEntity]
}

resource backendToApi 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend-api'
  properties: {
    parentEntityName: 'backend'
    childEntityName: 'api'
  }
  dependsOn: [backendEntity, apiEntity]
}

resource backendToWorker 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend-worker'
  properties: {
    parentEntityName: 'backend'
    childEntityName: 'worker'
  }
  dependsOn: [backendEntity, workerEntity]
}

resource dataToDatabase 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'data-database'
  properties: {
    parentEntityName: 'data'
    childEntityName: 'database'
  }
  dependsOn: [dataEntity, databaseEntity]
}

resource dataToCache 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'data-cache'
  properties: {
    parentEntityName: 'data'
    childEntityName: 'cache'
  }
  dependsOn: [dataEntity, cacheEntity]
}

output healthModelName string = healthModel.name
output healthModelId string = healthModel.id
output location string = healthModel.location
