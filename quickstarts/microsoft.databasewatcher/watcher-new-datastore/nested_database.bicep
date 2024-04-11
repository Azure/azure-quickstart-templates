param location string
param clusterName string
param principalId string
param tenantId string
param databaseName string

resource clusterName_database 'Microsoft.Kusto/clusters/databases@2023-05-02' = {
  name: '${clusterName}/${databaseName}'
  location: location
  kind: 'ReadWrite'
  properties: {}
}

resource clusterName_databaseName_id 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2023-05-02' = {
  parent: clusterName_database
  name: guid(resourceGroup().id)
  properties: {
    tenantId: tenantId
    principalId: principalId
    role: 'Admin'
    principalType: 'App'
  }
}