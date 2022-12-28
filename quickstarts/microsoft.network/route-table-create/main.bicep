@description('Route table name')
param routeTableName string = uniqueString(resourceGroup().id)

@description('Route table location')
param location string = resourceGroup().location

@description('Disable the routes learned by BGP on the route table')
param disableBgpRoutePropagation bool = false

@description('Array containing routes. For properties format refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/routetables?tabs=bicep#routepropertiesformat')
param routes array = []

@description('Enable delete lock')
param enableDeleteLock bool = false

var lockName = '${routeTable.name}-lck'

resource routeTable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [for route in routes: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        hasBgpOverride: contains(route, 'hasBgpOverride') ? route.hasBgpOverride : null
        nextHopIpAddress: contains(route, 'nextHopIpAddress') ? route.nextHopIpAddress : null
        nextHopType: route.nextHopType
      }
    }]
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: routeTable
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output name string = routeTable.name
output id string = routeTable.id
