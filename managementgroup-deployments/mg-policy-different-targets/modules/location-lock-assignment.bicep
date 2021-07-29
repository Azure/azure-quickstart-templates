targetScope = 'managementGroup'

@description('Policy definition unique identifier')
param policyDefinitionId string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'location-lock'
  properties: {
    policyDefinitionId: policyDefinitionId
  }
}
