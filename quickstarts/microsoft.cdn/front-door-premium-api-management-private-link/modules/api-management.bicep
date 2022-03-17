@description('The location into which the API Management resources should be deployed.')
param location string

@description('The name of the API Management service instance to create. This must be globally unique.')
param serviceName string

@description('The name of the API publisher. This information is used by API Management.')
param publisherName string

@description('The email address of the API publisher. This information is used by API Management.')
param publisherEmail string

@description('The name of the SKU to use when creating the API Management service instance. This must be a SKU that supports private endpoints.')
@allowed([
  'Premium'
  'Standard'
  'Basic'
  'Developer'
])
param skuName string

@description('The number of worker instances of your API Management service that should be provisioned.')
param skuCount int

resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: serviceName
  location: location
  sku: {
    name: skuName
    capacity: skuCount
  }
  properties: {
    publisherName: publisherName
    publisherEmail: publisherEmail
    publicNetworkAccess: 'Disabled'
  }
}

output apiManagementProxyHostName string = apiManagementService.properties.hostnameConfigurations[0].hostName
output apiManagementDeveloperPortalHostName string = replace(apiManagementService.properties.developerPortalUrl, 'https://', '')
output apiManagementResourceId string = apiManagementService.id
output apiManagementLocation string = apiManagementService.location
