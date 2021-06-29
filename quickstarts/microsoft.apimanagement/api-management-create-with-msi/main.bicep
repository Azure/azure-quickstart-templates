@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Basic'
  'Consumption'
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: 'apiservice${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}
