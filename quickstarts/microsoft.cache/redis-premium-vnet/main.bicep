@description('The location of the existing Virtual Network and for the new Redis Cache.')
param location string = resourceGroup().location

@description('The name of the Azure Redis Cache to create.')
param redisCacheName string

@description('The size of the new Azure Redis Cache instance. Valid capacity combinations are (P1..P5).')
@allowed([
  1
  2
  3
  4
  5
])
param redisCacheCapacity int = 1

@description('The resource group of the existing Virtual Network.')
param existingVirtualNetworkResourceGroupName string = resourceGroup().name

@description('The name of the existing Virtual Network.')
param existingVirtualNetworkName string

@description('The name of the existing subnet.')
param existingSubnetName string

@description('Set to true to allow access to redis on port 6379, without SSL tunneling (less secure).')
param enableNonSslPort bool = false

@description('The minimum allowed TLS version.')
@allowed([
  '1.0'
  '1.1'
  '1.2'
])
param minimumTlsVersion string = '1.2'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' existing = {
  name: '${existingVirtualNetworkName}/${existingSubnetName}'
  scope: resourceGroup(existingVirtualNetworkResourceGroupName)
}

resource redisCache 'Microsoft.Cache/redis@2020-12-01' = {
  name: redisCacheName
  location: location
  properties: {
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: minimumTlsVersion
    sku: {
      capacity: redisCacheCapacity
      family: 'P'
      name: 'Premium'
    }
    subnetId: subnet.id
  }
}
