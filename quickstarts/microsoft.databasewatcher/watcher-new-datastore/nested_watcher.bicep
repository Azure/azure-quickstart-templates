param name string
param location string
param clusterName string
param kustoDataIngestionUri string
param kustoClusterUri string
param kustoOfferingType string
param identityType string
param databaseName string = 'DEFAULT_DATABASE_NAME'

resource watcher 'Microsoft.DatabaseWatcher/watchers@2023-09-01-preview' = {
  name: name
  location: location
  identity: {
    type: identityType
  }
  properties: {
    datastore: {
      adxClusterResourceId: resourceId('Microsoft.Kusto/Clusters', clusterName)
      kustoClusterDisplayName: clusterName
      kustoDatabaseName: databaseName
      kustoClusterUri: kustoClusterUri
      kustoDataIngestionUri: kustoDataIngestionUri
      kustoManagementUrl: '${environment().portal}/resource/subscriptions${resourceId('Microsoft.Kusto/Clusters', clusterName)}/overview'
      kustoOfferingType: kustoOfferingType
    }
  }
}

output principalId string = watcher.identity.principalId
output tenantId string = watcher.identity.tenantId
