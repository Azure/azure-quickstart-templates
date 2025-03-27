param applicationGatewayUserDefinedManagedIdentityId string
param applicationGatewayId string
param aksClusterIngressApplicationGatewayObjectId string

var managedIdentityOperatorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'f1a07417-d97a-45cb-824c-7a7467783830')
var readerRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// AGIC's identity requires "Managed Identity Operator" permission over the user assigned identity of Application Gateway.
resource applicationGatewayAgicManagedIdentityOperatorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: guid(subscription().id, applicationGatewayUserDefinedManagedIdentityId, 'managedIdentityOperator')
  properties: {
    roleDefinitionId: managedIdentityOperatorRoleDefinitionId
    principalType: 'ServicePrincipal'
    principalId: aksClusterIngressApplicationGatewayObjectId
    //aksClusterIngressApplicationGatewayObjectId
  }
}

resource applicationGatewayAgicContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: guid(resourceGroup().id, applicationGatewayId, 'contributor')
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalType: 'ServicePrincipal'
    principalId: aksClusterIngressApplicationGatewayObjectId
  }
}

resource applicationGatewayAgicReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: guid(resourceGroup().id, applicationGatewayId, 'reader')
  properties: {
    roleDefinitionId: readerRoleDefinitionId
    principalType: 'ServicePrincipal'
    principalId: aksClusterIngressApplicationGatewayObjectId
  }
}
