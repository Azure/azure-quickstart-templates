@description('Specify the name of the Azure Redis Cache to create.')
param redisCacheName string

@description('Location of all resources')
param location string = resourceGroup().location

@description('Specify the pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisCacheSKU string = 'Premium'

@description('Specify the family for the sku. C = Basic/Standard, P = Premium.')
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

@description('Set to true to allow access to redis on port 6379, without SSL tunneling (less secure).')
param enableNonSslPort bool = false

@description('Specify a boolean value that indicates whether diagnostics should be saved to the specified storage account.')
param diagnosticsEnabled bool = true

@description('Specify an existing storage account for diagnostics. Must be in the same subscription.')
param existingDiagnosticsStorageAccountId string

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
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = {
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
