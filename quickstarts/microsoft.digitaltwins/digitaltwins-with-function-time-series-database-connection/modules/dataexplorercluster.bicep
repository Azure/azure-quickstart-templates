@description('Name given to Azure Data Explorer cluster resource')
param adxClusterName string

@description('Name given to database')
param databaseName string

@description('Azure Data Explorer cluster SKU option')
param clusterPlan string

@description('Azure Data Explorer cluster capacity')
param clusterCapacity int

@description('Azure Data Explorer cluster tier')
param clusterTier string

@description('The time to keep database data in cache')
param hotCachePeriod string

@description('The time data is kept in database')
param softDeletePeriod string

@description('Location of to be created resources')
param location string

// Creates Azure Data Explorer cluster
resource adxCluster 'Microsoft.Kusto/Clusters@2022-11-11' = {
  name: adxClusterName
  location: location
  sku: {
    capacity: clusterCapacity
    name: clusterPlan
    tier: clusterTier
  }
  identity: {
    type: 'None'
  }
  properties: {
    enableAutoStop: false
  }
}

// Creates database under the Azure Data Explorer cluster
resource database 'Microsoft.Kusto/clusters/databases@2022-11-11' = {
  name: '${adxCluster.name}/${databaseName}'
  location: location
  kind: 'ReadWrite'
  properties: {
    hotCachePeriod: hotCachePeriod
    softDeletePeriod: softDeletePeriod
  }
}
