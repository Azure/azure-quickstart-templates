@description('Specifies the name of the app configuration store.')
param configStoreName string

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

@description('Specifies the SKU of the app configuration store.')
param skuName string = 'standard'

resource configStoreName_resource 'Microsoft.AppConfiguration/configurationStores@2019-10-01' = {
  name: configStoreName
  location: location
  sku: {
    name: skuName
  }
}