@description('The location into which the API Management resources should be deployed.')
param location string

@description('The name of the API Management service instance to create. This must be globally unique.')
param serviceName string

@description('The name of the API publisher. This information is used by API Management.')
param publisherName string

@description('The email address of the API publisher. This information is used by API Management.')
param publisherEmail string

@description('The name of the SKU to use when creating the API Management service instance. This must be a SKU that supports virtual network integration.')
@allowed([
  'Developer'
  'Premium'
])
param skuName string

@description('The number of worker instances of your API Management service that should be provisioned.')
param skuCount int

@description('The type of virtual network integration to deploy. In \'External\' mode, a public IP address will be associated with the API Management service instance. In \'Internal\' mode, the instance is only accessible using private networking.')
@allowed([
  'External'
  'Internal'
])
param virtualNetworkType string

@description('The resource ID of the virtual network subnet that the API Management service instance should be deployed into.')
param subnetResourceId string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: serviceName
  location: location
  sku: {
    name: skuName
    capacity: skuCount
  }
  properties: {
    publisherName: publisherName
    publisherEmail: publisherEmail
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: {
      subnetResourceId: subnetResourceId
    }
  }
}

output apiManagementInternalIPAddress string = apiManagementService.properties.publicIPAddresses[0]
output apiManagementProxyHostName string = apiManagementService.properties.hostnameConfigurations[0].hostName
output apiManagementDeveloperPortalHostName string = replace(apiManagementService.properties.developerPortalUrl, 'https://', '')
