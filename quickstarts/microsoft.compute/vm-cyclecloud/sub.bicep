targetScope = 'subscription'

param location string = 'eastus'

resource rg 'Microsoft.Resources/resourceGroups@2019-05-01' = {
  name: 'rg-bicep'
  location: location
}
