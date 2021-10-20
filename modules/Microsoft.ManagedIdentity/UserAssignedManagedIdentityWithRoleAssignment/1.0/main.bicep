@description('The name of the managed identity resource.')
param managedIdentityName string

@description('A globally unique identifier (GUID) to identify the role assignment. The name of the role assignment must be unique within the resource group.')
@minLength(36)
@maxLength(36)
param roleAssignmentName string = guid(managedIdentityName, resourceGroup().id, roleDefinitionResourceId)

@description('The fully qualified Azure resource ID of the role definition to assign. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles for all built-in role definitions. For example, use `subscriptionResourceId(\'b24988ac-6180-42a0-ab88-20f7382dd24c\'` for the Contributor role. You can also use a custom role definition\'s resource ID.')
@minLength(50)
param roleDefinitionResourceId string

@description('An optional description of the role assignment, such as the reason this managed identity needs to be granted the role.')
param roleAssignmentDescription string = ''

@description('The Azure location where the managed identity should be created.')
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  scope: resourceGroup()
  properties: {
    description: roleAssignmentDescription
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleDefinitionResourceId
    principalType: 'ServicePrincipal' // See https://docs.microsoft.com/azure/role-based-access-control/role-assignments-template#new-service-principal for information about why this property is included.
  }
}

@description('The ID of the Azure AD application associated with the managed identity.')
output managedIdentityClientId string = managedIdentity.properties.clientId

@description('The ID of the Azure AD service principal associated with the managed identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

@description('The ID of the tenant which the managed identity belongs to.')
output managedIdentityTenantId string = managedIdentity.properties.tenantId

@description('The name of the role assignment.')
output roleAssignmentName string = roleAssignment.name
