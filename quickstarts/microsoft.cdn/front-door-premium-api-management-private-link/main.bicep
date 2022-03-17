@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location

@description('The name of the API Management service instance to create. This must be globally unique.')
param apiManagementServiceName string = 'apim-${uniqueString(resourceGroup().id)}'

@description('The name of the API publisher. This information is used by API Management.')
param apiManagementPublisherName string

@description('The email address of the API publisher. This information is used by API Management.')
param apiManagementPublisherEmail string

@description('The name of the SKU to use when creating the API Management service instance. This must be a SKU that supports private endpoints.')
@allowed([
  'Premium'
  'Standard'
  'Basic'
  'Developer'
])
param apiManagementSkuName string = 'Developer'

@description('The number of worker instances of your API Management service that should be provisioned.')
param apiManagementSkuCount int = 1

@description('The name of the Front Door endpoint to create for the API Management proxy gateway. This must be globally unique.')
param frontDoorProxyEndpointName string = 'afd-proxy-${uniqueString(resourceGroup().id)}'

module apiManagementDeployment1 'modules/api-management.bicep' = {
  name: 'api-management-1'
  params: {
    location: location
    serviceName: apiManagementServiceName
    publisherName: apiManagementPublisherName
    publisherEmail: apiManagementPublisherEmail
    skuName: apiManagementSkuName
    skuCount: apiManagementSkuCount
    publicNetworkAccess: 'Enabled'
  }
}

module frontDoor 'modules/front-door.bicep' = {
  name: 'front-door'
  params: {
    proxyEndpointName: frontDoorProxyEndpointName
    proxyOriginHostName: apiManagementDeployment1.outputs.apiManagementProxyHostName
    apiManagementResourceId: apiManagementDeployment1.outputs.apiManagementResourceId
    apiManagementLocation: apiManagementDeployment1.outputs.apiManagementLocation
  }
}

module apiManagementDeployment2 'modules/api-management.bicep' = {
  name: 'api-management-2'
  dependsOn: [
    frontDoor
  ]
  params: {
    location: location
    serviceName: apiManagementServiceName
    publisherName: apiManagementPublisherName
    publisherEmail: apiManagementPublisherEmail
    skuName: apiManagementSkuName
    skuCount: apiManagementSkuCount
    publicNetworkAccess: 'Disabled'
  }
}

output frontDoorEndpointApiManagementProxyHostName string = frontDoor.outputs.frontDoorProxyEndpointHostName
output apiManagementProxyHostName string = apiManagementDeployment2.outputs.apiManagementProxyHostName
output apiManagementPortalHostName string = apiManagementDeployment2.outputs.apiManagementDeveloperPortalHostName
