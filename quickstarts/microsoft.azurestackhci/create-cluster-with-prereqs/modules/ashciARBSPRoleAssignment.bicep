targetScope = 'subscription'

param arbDeploymentSPObjectId string

var ARBDeploymentRoleID = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','7b1f81f9-4196-4058-8aae-762e593270df')

resource ARBServicePrincipalResourceBridgeDeploymentRolePermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('ARBServicePrincipalResourceBridgeDeploymentRolePermissions',subscription().id,arbDeploymentSPObjectId)
  properties:  {
    roleDefinitionId: ARBDeploymentRoleID
    principalId: arbDeploymentSPObjectId
    principalType: 'ServicePrincipal'
    description: 'Created by Azure Stack HCI deployment template'
  }
}
