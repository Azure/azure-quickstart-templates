@description('Specify the name of the Azure Redis Cache to create.')
param redisCacheName string

@description('Name of the storage account.')
param storageAccountName string

@description('The location of the Redis Cache. For best performance, use the same location as the app to be used with the cache.')
param location string = resourceGroup().location

@description('Specify the pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisCacheSKU string = 'Premium'

@description('Specify the family for the sku. C = Basic/Standard, P = Premium')
@allowed([
  'C'
  'P'
])
param redisCacheFamily string = 'P'

@description('Specify the size of the new Azure Redis Cache instance. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4)')
@allowed([
  0
  1
  2
  3
  4
  5
  6
])
param redisCacheCapacity int = 1

@description('Specify a boolean value that indicates whether to allow access via non-SSL ports.')
param enableNonSslPort bool = false

@description('Specify a boolean value that indicates whether diagnostics should be saved to the specified storage account.')
param diagnosticsEnabled bool = true

@description('Specify an existing storage account for diagnostics.')
param existingDiagnosticsStorageAccountId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

var cacheAccountKey = storageAccount.listKeys().keys[0].value

resource cache 'Microsoft.Cache/Redis@2020-06-01' = {
  name: redisCacheName
  location: location
  properties: {
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: '1.2'
    sku: {
      capacity: redisCacheCapacity
      family: redisCacheFamily
      name: redisCacheSKU
    }
    redisConfiguration: {
      'rdb-backup-enabled': 'true'
      'rdb-backup-frequency': '60'
      'rdb-backup-max-snapshot-count': '1'
      'rdb-storage-connection-string': 'DefaultEndpointsProtocol=https;BlobEndpoint=https://${storageAccount.name}.blob.${environment().suffixes.storage};AccountName=${storageAccount.name};AccountKey=${cacheAccountKey}'
    }
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: cache
  name: redisCacheName
  properties: {
    storageAccountId: existingDiagnosticsStorageAccountId
    metrics: [
      {
        timeGrain: 'AllMetrics'
        enabled: diagnosticsEnabled
        retentionPolicy: {
          days: 90
          enabled: diagnosticsEnabled
        }
      }
    ]
  }
}
