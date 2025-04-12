@description('The name of the Azure Data Explorer cluster')
@minLength(4)
@maxLength(22)
param clusterName string

@description('The location (Azure region) of the Azure Data Explorer cluster')
param clusterLocation string

@description('The SKU of the Azure Data Explorer cluster')
param clusterSkuName string

@description('The SKU tier of the Azure Data Explorer cluster')
param clusterSkuTier string

@description('The name of the Azure Data Explorer database')
@minLength(1)
@maxLength(260)
param kustoDatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2023-05-02' = {
  name: clusterName
  location: clusterLocation
  tags: {}
  sku: {
    capacity: 2
    name: clusterSkuName
    tier: clusterSkuTier
  }
  identity: {
    type: 'None'
  }
  properties: {
    enableAutoStop: false
    enableDiskEncryption: true
    enableDoubleEncryption: false
    enableStreamingIngest: true
    enablePurge: true
    engineType: 'V3'
    optimizedAutoscale: {
      isEnabled: false
      minimum: 2
      maximum: 2
      version: 1
    }
    publicIPType: 'IPv4'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource kustoDatabase 'Microsoft.Kusto/clusters/databases@2023-05-02' = {
  parent: cluster
  name: kustoDatabaseName
  location: clusterLocation
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P365D'
    hotCachePeriod: 'P31D'
  }
}

output adxClusterResourceId string = cluster.id
output adxClusterUri string = cluster.properties.uri
output adxDataIngestionUri string = cluster.properties.dataIngestionUri
