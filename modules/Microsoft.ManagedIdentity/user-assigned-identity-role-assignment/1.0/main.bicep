@description('The name of the managed identity resource.')
param managedIdentityName string

@description('The IDs of the role definitions to assign to the managed identity. Each role assignment is created at the resource group scope. Role definition IDs are GUIDs. To find the GUID for built-in Azure role definitions, see https://docs.microsoft.com/azure/role-based-access-control/built-in-roles. You can also use IDs of custom role definitions.')
param roleDefinitionIds array

@description('An optional description to apply to each role assignment, such as the reason this managed identity needs to be granted the role.')
param roleAssignmentDescription string = ''

@description('The Azure location where the managed identity should be created.')
param location string = resourceGroup().location

var roleAssignmentsToCreate = [for roleDefinitionId in roleDefinitionIds: {
  name: guid(managedIdentity.id, resourceGroup().id, roleDefinitionId)
  roleDefinitionId: roleDefinitionId
}]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleAssignmentToCreate in roleAssignmentsToCreate: {
  name: roleAssignmentToCreate.name
  scope: resourceGroup()
  properties: {
    description: roleAssignmentDescription
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignmentToCreate.roleDefinitionId)
    principalType: 'ServicePrincipal' // See https://docs.microsoft.com/azure/role-based-access-control/role-assignments-template#new-service-principal to understand why this property is included.
  }
}]

@description('The resource ID of the user-assigned managed identity.')
output managedIdentityResourceId string = managedIdentity.id

@description('The ID of the Azure AD application associated with the managed identity.')
output managedIdentityClientId string = managedIdentity.properties.clientId

@description('The ID of the Azure AD service principal associated with the managed identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
