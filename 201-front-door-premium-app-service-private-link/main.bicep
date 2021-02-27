param location string {
  allowed:[
    'eastus'
    'westus2'
    'southcentralus'
  ]
  default: 'eastus'
  metadata: {
    description: 'The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.'
  }
}
param appName string {
  default: 'myapp-${uniqueString(resourceGroup().id)}'
  metadata: {
    description: 'The name of the App Service application to create. This must be globally unique.'
  }
}
param appServicePlanSkuName string {
  default: 'P1v2'
  metadata: {
    description: 'The name of the SKU to use when creating the App Service plan. This must be a SKU that is compatible with private endpoints, i.e. P1v2 or better.'
  }
}
param appServicePlanCapacity int {
  default: 1
  metadata: {
    description: 'The number of worker instances of your App Service plan that should be provisioned.'
  }
}
param frontDoorEndpointName string {
  default: 'afd-${uniqueString(resourceGroup().id)}'
  metadata: {
    description: 'The name of the Front Door endpoint to create. This must be globally unique.'
  }
}
var frontDoorSkuName = 'Premium_AzureFrontDoor' // Private Link origins require the premium SKU.

module appService 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    appName: appName
    appServicePlanSkuName: appServicePlanSkuName
    appServicePlanCapacity: appServicePlanCapacity
  }
}

module frontDoor 'modules/front-door.bicep' = {
  name: 'front-door'
  params: {
    skuName: frontDoorSkuName
    endpointName: frontDoorEndpointName
    originHostName: appService.outputs.appHostName
    privateEndpointResourceId: appService.outputs.appServiceResourceId
    privateLinkResourceType: 'sites' // For App Service and Azure Functions, this needs to be 'sites'.
    privateEndpointLocation: location
  }
}

output appServiceHostName string = appService.outputs.appHostName
output frontDoorEndpointHostName string = frontDoor.outputs.frontDoorEndpointHostName
