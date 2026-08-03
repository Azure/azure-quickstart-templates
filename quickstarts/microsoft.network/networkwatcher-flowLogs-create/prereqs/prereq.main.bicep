@description('Address prefix')
param addressPrefix string = '10.0.0.0/16'

@description('Subnet-1 Prefix')
param subnetPrefix string = '10.0.0.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

var virtualNetworkName = 'virtualNetwork1'
var subnetName = 'subnet'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

output existingVNet string = virtualNetwork.id
