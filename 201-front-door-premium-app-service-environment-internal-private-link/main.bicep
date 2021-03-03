@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.')
@allowed([
  'eastus'
  'westus2'
  'southcentralus'
])
param location string

@description('The IP address prefix (CIDR range) to use when deploying the virtual network.')
param vnetIPPrefix string = '10.0.0.0/16'

@description('The IP address prefix (CIDR range) to use when deploying the App Service environment subnet within the virtual network.')
param appServiceEnvironmentSubnetIPPrefix string = '10.0.0.0/24'

@description('The name of the App Service environment to create. This must be globally unique.')
param appServiceEnvironmentName string = 'ase-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service application to create. This must be globally unique.')
param appName string = 'app-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the App Service plan. This must be a SKU that is compatible with App Service environments, i.e. I1 or better.')
param appServicePlanSkuName string = 'I1'

@description('The number of worker instances of your App Service plan that should be provisioned.')
param appServicePlanCapacity int = 1

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

var frontDoorSkuName = 'Premium_AzureFrontDoor'

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    vnetIPPrefix: vnetIPPrefix
    appServiceEnvironmentSubnetIPPrefix: appServiceEnvironmentSubnetIPPrefix
  }
}

module appServiceEnvironment 'modules/app-service-environment.bicep' = {
  name: 'app-service-environment'
  params: {
    location: location
    appServiceEnvironmentName: appServiceEnvironmentName
    subnetResourceId: network.outputs.appServiceEnvironmentSubnetResourceId
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
    originHostName: appServiceEnvironment.outputs.appHostName
    privateEndpointResourceId: appServiceEnvironment.outputs.appServiceResourceId
    privateLinkResourceType: 'sites' // For App Service and Azure Functions, this needs to be 'sites'.
    privateEndpointLocation: location
  }
}

output appServiceHostName string = appServiceEnvironment.outputs.appHostName
output frontDoorEndpointHostName string = frontDoor.outputs.frontDoorEndpointHostName
