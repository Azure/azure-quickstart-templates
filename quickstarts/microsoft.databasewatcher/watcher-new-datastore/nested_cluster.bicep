param location string
param createNewDatastore bool
param clusterName string = ''
param clusterSkuName string = ''
param clusterSkuTier string = ''

resource cluster 'Microsoft.Kusto/clusters@2023-08-15' = if (createNewDatastore == bool('true')) {
  name: clusterName
  location: location
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
    enableAutoStop: true
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

output kustoDataIngestionUri string = cluster.properties.dataIngestionUri
output kustoClusterUri string = cluster.properties.uri
