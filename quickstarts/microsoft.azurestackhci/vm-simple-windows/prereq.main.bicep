param virtualNetworkName string
param vmSwitchName string
param location string = 'eastus'
param customLocationName string = 'hcicluster-cl'

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)

resource virtualNetwork 'Microsoft.AzureStackHCI/virtualNetworks@2022-12-15-preview' = {
  name: virtualNetworkName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    networkType: 'Transparent'
    subnets: []
    vmSwitchName: vmSwitchName
    dhcpOptions: {}
  }
}
