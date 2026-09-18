targetScope = 'resourceGroup'

@description('Name of the existing target PostgreSQL Flexible Server.')
param postgresServerName string

@description('Object ID of the Automation Account managed identity.')
param principalId string

@description('Resource ID of the Automation Account.')
param automationAccountResourceId string

var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' existing = {
  name: postgresServerName
}

resource serverContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: postgresServer
  name: guid(postgresServer.id, automationAccountResourceId, contributorRoleDefinitionId)
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinitionId
  }
}
