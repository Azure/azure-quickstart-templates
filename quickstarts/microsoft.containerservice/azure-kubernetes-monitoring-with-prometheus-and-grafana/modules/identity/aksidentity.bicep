param location string
param prefix string

resource aksManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: '${prefix}-aks'
  location: location
}

resource aksRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  scope: subscription()
}

resource aksRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, aksRoleDefinition.id)
  scope: resourceGroup()
  properties: {
    principalId: aksManagedIdentity.properties.principalId
    roleDefinitionId: aksRoleDefinition.id//'7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

output aksManagedIdentityId string = aksManagedIdentity.id
output aksManagedIdentityPrincipalId string = aksManagedIdentity.properties.principalId
