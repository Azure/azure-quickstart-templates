// Assigns the necessary roles to the AI project

param storageName string
param UAIPrincipalId string
param suffix string

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageName
  scope: resourceGroup()
}

// search roles
resource storageBlobDataOwner 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  scope: resourceGroup()
}

resource storageBlobDataOwnerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(suffix, storageBlobDataOwner.id, storage.id)
  properties: {
    principalId: UAIPrincipalId
    roleDefinitionId: storageBlobDataOwner.id
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
  scope: resourceGroup()
}

resource storageQueueDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(suffix, storageQueueDataContributor.id, storage.id)
  properties: {
    principalId: UAIPrincipalId
    roleDefinitionId: storageQueueDataContributor.id
    principalType: 'ServicePrincipal'
  }
}
