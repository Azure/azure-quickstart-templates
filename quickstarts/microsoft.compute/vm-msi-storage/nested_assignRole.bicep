param storageAccountName string
param assignedRoleDefinitionId string
param principalId string

var roleName = guid(assignedRoleDefinitionId, principalId, storageAccountName)

resource storageAccountName_Microsoft_Authorization_role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleName
  properties: {
    roleDefinitionId: assignedRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
