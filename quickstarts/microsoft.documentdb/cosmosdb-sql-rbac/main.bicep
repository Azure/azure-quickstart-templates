@description('Location for all resources.')
param location string = resourceGroup().location

@description('Cosmos DB account name, max length 44 characters')
param accountName string = 'sql-rbac-${uniqueString(resourceGroup().id)}'

@description('Friendly name for the SQL Role Definition')
param roleDefinitionName string = 'My Read Write Role'

@description('Data actions permitted by the Role Definition')
param dataActions array = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]

@description('Object ID of the AAD identity. Must be a GUID.')
param principalId string

var account_name = toLower(accountName)
var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]
var roleDefinitionId = guid('sql-role-definition-', accountName_resource.id)
var roleAssignmentId = guid('sql-role-assignment-', accountName_resource.id)

resource accountName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: account_name
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
  }
}

resource accountName_roleDefinitionId 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' = {
  name: '${accountName_resource.name}/${roleDefinitionId}'
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      accountName_resource.id
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource accountName_roleAssignmentId 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  name: '${accountName_resource.name}/${roleAssignmentId}'
  properties: {
    roleDefinitionId: accountName_roleDefinitionId.id
    principalId: principalId
    scope: accountName_resource.id
  }
}
