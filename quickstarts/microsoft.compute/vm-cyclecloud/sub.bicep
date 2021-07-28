targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2019-05-01' = {
  name: 'rg-bicep'
  location: 'eastus'
}
