@description('The name of the Azure Data Explorer cluster')
@minLength(4)
@maxLength(22)
param clusterName string

@description('The name of the Azure Data Explorer database')
@minLength(1)
@maxLength(260)
param kustoDatabaseName string

@description('The resource ID of the watcher.')
param watcherResourceId string

@description('The identity of the watcher.')
param watcherIdentity object

resource adxDatabase 'Microsoft.Kusto/clusters/databases@2023-08-15' existing = {
  name: '${clusterName}/${kustoDatabaseName}'
}

resource adxDatabaseRoleAssignment 'Microsoft.Kusto/clusters/databases/principalAssignments@2023-08-15' = {
  parent: adxDatabase
  name: guid(watcherResourceId, adxDatabase.id)
  properties: {
    tenantId: watcherIdentity.tenantId
    principalId: watcherIdentity.principalId
    role: 'Admin'
    principalType: 'App'
  }
}
