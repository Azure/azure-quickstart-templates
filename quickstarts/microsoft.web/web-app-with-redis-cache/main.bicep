@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param skuName string = 'F1'

@description('Describes plan\'s instance count')
@minValue(1)
@maxValue(7)
param skuCapacity int = 1

@description('The pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
])
param cacheSKUName string = 'Basic'

@description('The family for the sku.')
@allowed([
  'C'
])
param cacheSKUFamily string = 'C'

@description('The size of the new Azure Redis Cache instance. ')
@minValue(0)
@maxValue(6)
param cacheSKUCapacity int = 0

@description('Location for all resources.')
param location string = resourceGroup().location

var hostingPlanName = 'hostingplan${uniqueString(resourceGroup().id)}'
var webSiteName = 'webSite${uniqueString(resourceGroup().id)}'
var cacheName = 'cache${uniqueString(resourceGroup().id)}'

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  tags: {
    displayName: 'HostingPlan'
  }
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {
  }
}

resource webSite 'Microsoft.Web/sites@2021-03-01' = {
  name: webSiteName
  location: location
  tags: {
    'hidden-related:${hostingPlan.id}': 'empty'
    displayName: 'Website'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
  }
  dependsOn: [
    cache
  ]
}

resource appsettings 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: webSite
  name: 'appsettings'
  properties: {
    CacheConnection: '${cacheName}.redis.cache.windows.net,abortConnect=false,ssl=true,password=${cache.listKeys().primaryKey}'
    minTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
  }
}

resource cache 'Microsoft.Cache/Redis@2021-06-01' = {
  name: cacheName
  location: location
  tags: {
    displayName: 'cache'
  }
  properties: {
    sku: {
      name: cacheSKUName
      family: cacheSKUFamily
      capacity: cacheSKUCapacity
    }
  }
}
