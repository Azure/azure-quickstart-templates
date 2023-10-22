@description('Principal ID to set the access for')
param principalId string

@description('The storage account to set access for')
param storageAccountName string

var scope = resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
var RBACResourceName = guid(scope, contributorRoleDefinition.id, principalId)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}
resource storageAccountName_Microsoft_Authorization_RBACResource 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: RBACResourceName
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Azure contributor role
}
