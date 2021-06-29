@description('The location into which the App Service resources should be deployed. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.')
@allowed([
  'eastus'
  'westus2'
  'southcentralus'
])
param location string

@description('The name of the App Service application to create. This must be globally unique.')
param appName string

@description('The name of the SKU to use when creating the App Service plan. This must be a SKU that is compatible with private endpoints, i.e. P1v2 or better.')
param appServicePlanSkuName string

@description('The number of worker instances of your App Service plan that should be provisioned.')
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
