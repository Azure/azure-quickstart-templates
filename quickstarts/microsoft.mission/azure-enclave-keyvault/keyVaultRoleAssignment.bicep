targetScope = 'resourceGroup'

param principalId string
param roleDefinitionId string
param resourceName string
param principalType string = 'User'

resource targetResource 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: resourceName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(targetResource.id, principalId, roleDefinitionId)
  scope: targetResource
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}
