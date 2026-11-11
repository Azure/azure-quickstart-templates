// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { getAppPublisherTags, HubAppProperties } from 'hub-types.bicep'


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app the identity is associated with.')
param app HubAppProperties

@description('Required. Name of the user assigned identity.')
param identityName string

@description('Required. Resource ID of the resource access is being granted for.')
param roleAssignmentResourceId string

@description('Required. List of RBAC role assignment GUIDs.')
param roles string[]


//==============================================================================
// Resources
//==============================================================================

// Create managed identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  tags: getAppPublisherTags(app, 'Microsoft.ManagedIdentity/userAssignedIdentities')
  location: app.hub.location
}

// Assign access to the identity
resource identityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in roles: {
  name: guid(roleAssignmentResourceId, role, identity.id)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]


//==============================================================================
// Outputs
//==============================================================================

@description('Resource ID of the user assigned identity.')
output id string = identity.id

@description('Name of the user assigned identity.')
output name string = identity.name

@description('Principal ID of the user assigned identity.')
output principalId string = identity.properties.principalId
