targetScope = 'resourceGroup'

@description('principalId of the user that will be given contributor access to the resourceGroup')
param principalId string

@description('roleDefinition to apply to the resourceGroup - default is contributor')
param roleDefinitionId string

@description('Unique name for the roleAssignment in the format of a guid')
param roleAssignmentName string

resource dontDeleteLock 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'DontDelete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Prevent deletion of the resourceGroup'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleAssignmentName)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
  }
}
