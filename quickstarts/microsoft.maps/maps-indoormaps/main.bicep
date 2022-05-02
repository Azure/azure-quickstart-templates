@description('The name for your Azure Maps account. This value must be globally unique.')
param accountName string = uniqueString(resourceGroup().id)

@description('Total available storage units shared across all Creator services. Allowable value between 1 and 100 units. Each unit corresponds to 1 MiB')
@minValue(1)
@maxValue(100)
param creatorStorageUnits int = 1

@description('Location of the Creator Service')
@allowed([
  'East US 2'
  'West US 2'
  'North Europe'
  'West Europe'
])
param creatorLocation string = 'East US 2'

resource mapsResource 'Microsoft.Maps/accounts@2021-02-01' = {
  name: accountName
  location: 'global'
  sku: {
    name: 'G2'
  }
}

resource creatorResource 'Microsoft.Maps/accounts/creators@2021-02-01' = {
  parent: mapsResource
  name: 'creator'
  location: creatorLocation
  properties: {
    storageUnits: creatorStorageUnits
  }
}
