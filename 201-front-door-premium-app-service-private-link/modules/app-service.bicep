param location string
param appName string
param appServicePlanSkuName string
param appServicePlanCapacity int

var appServicePlanName = 'AppServicePlan'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    capacity: appServicePlanCapacity
  }
  kind: 'app'
}

resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output appHostName string = app.properties.defaultHostName
output appServiceResourceId string = app.id
output appServiceLocation string = app.location
