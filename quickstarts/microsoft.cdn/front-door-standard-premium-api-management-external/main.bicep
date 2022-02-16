@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location

@description('The IP address prefix (CIDR range) to use when deploying the virtual network.')
param vnetIPPrefix string = '10.0.0.0/16'

@description('The IP address prefix (CIDR range) to use when deploying the API Management subnet within the virtual network.')
param apiManagementSubnetIPPrefix string = '10.0.0.0/24'

@description('The name of the API Management service instance to create. This must be globally unique.')
param apiManagementServiceName string = 'apim-${uniqueString(resourceGroup().id)}'

@description('The name of the API publisher. This information is used by API Management.')
param apiManagementPublisherName string = 'Contoso'

@description('The email address of the API publisher. This information is used by API Management.')
param apiManagementPublisherEmail string = 'admin@contoso.com'

@description('The name of the SKU to use when creating the API Management service instance. This must be a SKU that supports virtual network integration.')
@allowed([
  'Developer'
  'Premium'
])
param apiManagementSku string = 'Developer'

@description('The number of worker instances of your API Management service that should be provisioned.')
param apiManagementSkuCount int = 1

@description('The name of the Front Door endpoint to create for the API Management proxy gateway. This must be globally unique.')
param frontDoorProxyEndpointName string = 'afd-proxy-${uniqueString(resourceGroup().id)}'

@description('The name of the Front Door endpoint to create for the API Management developer portal. This must be globally unique.')
param frontDoorDeveloperPortalEndpointName string = 'afd-portal-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

var apiManagementFrontDoorIdNamedValueName = 'FrontDoorId'
var apiManagementVirtualNetworkType = 'External' // For this sample we use API Management's external VNet integration mode. Internal VNet integration is not currently possible with Front Door (as of March 2021).

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    vnetIPPrefix: vnetIPPrefix
    apiManagementSubnetIPPrefix: apiManagementSubnetIPPrefix
  }
}

module apiManagement 'modules/api-management.bicep' = {
  name: 'api-management'
  params: {
    location: location
    serviceName: apiManagementServiceName
    publisherName: apiManagementPublisherName
    publisherEmail: apiManagementPublisherEmail
    skuName: apiManagementSku
    skuCount: apiManagementSkuCount
    subnetResourceId: network.outputs.apiManagementSubnetResourceId
    virtualNetworkType: apiManagementVirtualNetworkType
  }
}

module frontDoor 'modules/front-door.bicep' = {
  name: 'front-door'
  params: {
    skuName: frontDoorSkuName
    proxyEndpointName: frontDoorProxyEndpointName
    developerPortalEndpointName: frontDoorDeveloperPortalEndpointName
    proxyOriginHostName: apiManagement.outputs.apiManagementProxyHostName
    developerPortalOriginHostName: apiManagement.outputs.apiManagementDeveloperPortalHostName
  }
}

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apiManagementServiceName

  resource frontDoorIdNamedValue 'namedValues' = {
    name: apiManagementFrontDoorIdNamedValueName
    dependsOn: [
      apiManagement
    ]
    properties: {
      displayName: 'FrontDoorId'
      value: frontDoor.outputs.frontDoorId
      secret: true
    }
  }
  
  resource globalPolicy 'policies' = {
    name: 'policy'
    dependsOn: [
      frontDoorIdNamedValue
    ]
    properties: {
      value: loadTextContent('api-management-policies/global.xml')
      format: 'xml'
    }
  }
}

output frontDoorEndpointApiManagementProxyHostName string = frontDoor.outputs.frontDoorProxyEndpointHostName
output frontDoorEndpointApiManagementPortalHostName string = frontDoor.outputs.frontDoorDeveloperPortalEndpointHostName
output apiManagementProxyHostName string = apiManagement.outputs.apiManagementProxyHostName
output apiManagementPortalHostName string = apiManagement.outputs.apiManagementDeveloperPortalHostName
