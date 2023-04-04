
@description('The AAD principal id of for the role-assignment.')
param principalId string

@description('The role id for the role-assignment.')
@allowed([
  'bcd981a7-7f74-457b-83e1-cceb9e632ffe' /* Azure Digital Twins Data Owner */
  'd57506d4-4c8d-48b1-8587-93c323f6a5a3' /* Azure Digital Twins Data Reader */
])
param roleId string

@description('The name of the Azure Digital Twins instance.')
param digitalTwinsInstanceName string

resource digitalTwinsInstance 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' existing = {
  name: digitalTwinsInstanceName
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(uniqueString(principalId, roleId, digitalTwinsInstance.id))
  scope: digitalTwinsInstance
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefintions', roleId)
  }
}
