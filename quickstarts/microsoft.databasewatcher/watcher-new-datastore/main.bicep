@description('Database watcher name')
param watcherName string

@description('The type of managed identity to assign to a watcher')
param identityType string

@description('The location (Azure region) of the watcher')
param location string = resourceGroup().location

@description('Set to true to create a new Azure Data Explorer cluster and database as the data store for the watcher')
param createNewDatastore bool

@description('The Kusto offering type of the data store. Supported values are: adx, free, fabric.')
param kustoOfferingType string = 'adx'

@description('The name of the Azure Data Explorer cluster')
param clusterName string

@description('The name of the Azure Data Explorer database')
param databaseName string = 'database-watcher-data-store'

@description('The SKU of the Azure Data Explorer cluster')
param clusterSkuName string

@description('The SKU tier of the Azure Data Explorer cluster')
param clusterSkuTier string

@description('The total number of SQL targets to add to a watcher')
param targetCount int

@description('The array of SQL target properties. Each element of the array defines a SQL target.')
param targetProperties array

module cluster './nested_cluster.bicep' = {
  name: clusterName
  params: {
    location: location
    createNewDatastore: createNewDatastore
    clusterName: clusterName
    clusterSkuName: clusterSkuName
    clusterSkuTier: clusterSkuTier
  }
}

module watcher './nested_watcher.bicep' = {
  name: watcherName
  params: {
    location: location
    kustoDataIngestionUri: cluster.outputs.kustoDataIngestionUri
    kustoClusterUri: cluster.outputs.kustoClusterUri
    identityType: identityType
    name: watcherName
    kustoOfferingType: kustoOfferingType
    clusterName: clusterName
    databaseName: databaseName
  }
}

module database './nested_database.bicep' = {
  name: databaseName
  params: {
    location: location
    clusterName: clusterName
    principalId: watcher.outputs.principalId
    tenantId: watcher.outputs.tenantId
    databaseName: databaseName
  }
}

resource target 'Microsoft.DatabaseWatcher/watchers/targets@2023-09-01-preview' = [for i in range(0, length(range(0, targetCount))): {
  name: '${watcherName}/${guid(resourceGroup().id, watcherName, string(i))}'
  properties: {
    targetType: targetProperties[i].targetType
    sqlDbResourceId: resourceId('Microsoft.SQL/servers/databases', targetProperties[i].targetLogicalServerName, targetProperties[i].targetDatabaseName)
    connectionServerName: concat(targetProperties[i].targetLogicalServerName, targetProperties[i].targetServerDnsSuffix)
    readIntent: targetProperties[i].readIntent
    targetAuthenticationType: targetProperties[i].targetAuthenticationType
  }
  dependsOn: [
    watcher
  ]
}]
