param location string {
  allowed:[
    'eastus'
    'westus2'
    'southcentralus'
  ]
  metadata: {
    description: 'When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.'
  }
}
param appName string
param appServicePlanSkuName string {
  metadata: {
    description: 'The SKU name to use for App Service. This must be a SKU that is compatible with private endpoints, i.e. P1v2 or better.'
  }
}
param appServicePlanCapacity int
param frontDoorEndpointName string

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
