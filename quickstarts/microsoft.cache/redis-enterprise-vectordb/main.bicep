@description('Location of all resources')
param location string = resourceGroup().location

@description('Name of the Redis Enterprise Cache')
param redisCacheName string = 'redisCache-${uniqueString(resourceGroup().id)}'

@description('SKU of the Redis Enterprise Cache')
param redisCacheSKU string = 'Enterprise_E10'

@description('Capacity of the Redis Enterprise Cache')
param redisCacheCapacity int = 2

@description('Eviction Policy of the Redis Enterprise Cache')
param evictionPolicy string = 'NoEviction'

@description('Port of the Redis Enterprise Cache')
param redisPort int = 10000

resource redisEnterprise 'Microsoft.Cache/redisEnterprise@2022-01-01' = {
  name: redisCacheName
  location: location
  sku: {
    name: redisCacheSKU
    capacity: redisCacheCapacity
  }
}

resource redisdatabase 'Microsoft.Cache/redisEnterprise/databases@2022-01-01' = {
  name: 'default'
  parent: redisEnterprise
  properties: {
    evictionPolicy: evictionPolicy
    clusteringPolicy: 'EnterpriseCluster'
    modules: [
      {
        name: 'RediSearch'
      }
      {
        name: 'RedisJSON'
      }
    ]
    port: redisPort
  }
}
