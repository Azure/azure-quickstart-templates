targetScope = 'subscription'

param devCenterName string
param resourceGroupName string
param guidSeed string

resource devcenter 'Microsoft.DevCenter/devcenters@2023-04-01' existing = {
  scope: resourceGroup(resourceGroupName)
  name: devCenterName
}

resource roleAssignment1 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('User Access Administrator', guidSeed)
  properties: {
    description: 'Lets you manage user access to Azure resources.'
    principalId: devcenter.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
  }
}

resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('Contributor', guidSeed)
  properties: {
    description: 'Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprints, or share image galleries.'
    principalId: devcenter.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  }
}
