@description('The name for your Azure Maps account. This value must be globally unique.')
param accountName string = uniqueString(resourceGroup().id)

@description('Specifies the location for all the resources.')
@allowed([
  'westeurope'
  'eastus'
  'westus2'
  'northeurope'
  'westcentralus'
  'usgovvirginia'
  'usgovarizona'
])
param location string

@description('The pricing tier SKU for the account.')
@allowed([
  'G2'
])
param pricingTier string = 'G2'

@description('The pricing tier for the account.')
@allowed([
  'Gen2'
])
param kind string = 'Gen2'

resource account 'Microsoft.Maps/accounts@2023-06-01' = {
  name: accountName
  location: location
  sku: {
    name: pricingTier
  }
  kind: kind
}
