@description('Principal ID to set the access for')
param principalId string

@description('The storage account to set access for')
param storageAccountName string

var contributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var scope = resourceId('Microsoft.Storage/storageAccounts', storageAccountName)
var RBACResourceName = guid(scope, contributor, principalId)

resource storageAccountName_Microsoft_Authorization_RBACResource 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2019-04-01-preview' = {
  name: '${storageAccountName}/Microsoft.Authorization/${RBACResourceName}'
  properties: {
    roleDefinitionId: contributor
    principalId: principalId
    scope: scope
    principalType: 'ServicePrincipal'
  }
}