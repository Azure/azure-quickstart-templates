
@description('The location into which the App Service environment resources should be deployed.')
param location string

@description('The name of the App Service environment to create. This must be globally unique.')
param appServiceEnvironmentName string

@description('The resource ID of the virtual network subnet that the App Service environment should be deployed into.')
param subnetResourceId string

@description('The name of the App Service application to create. This must be globally unique.')
param appName string

@description('The name of the SKU to use when creating the App Service plan. This must be a SKU that is compatible with App Service environments, i.e. I1 or better.')
param appServicePlanSkuName string

@description('The number of worker instances of your App Service plan that should be provisioned.')
param appServicePlanCapacity int

// For full details about creating an App Service environment using a template, see https://docs.microsoft.com/azure/app-service/environment/create-from-template.

var appServicePlanName = 'AppServicePlan'
var appServiceEnvironmentInternalLoadBalancingMode = 'None' // This is required in order to deploy a private endpoint.

resource appServiceEnvironment 'Microsoft.Web/hostingEnvironments@2020-06-01' = {
  name: appServiceEnvironmentName
  location: location
  kind: 'ASEV2'
  properties: {
    location: location
    name: appServiceEnvironmentName
    internalLoadBalancingMode: appServiceEnvironmentInternalLoadBalancingMode
    virtualNetwork: {
      id: subnetResourceId
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: 'Isolated'
    size: appServicePlanSkuName
    family: 'I'
    capacity: appServicePlanCapacity
  }
  kind: 'app'
  properties: {
    hostingEnvironmentProfile: {
      id: appServiceEnvironment.id
    }
  }
}

resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output appHostName string = app.properties.defaultHostName
output appServiceResourceId string = app.id
