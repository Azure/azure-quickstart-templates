param location string

param virtualNetworkName string
param virtualNetworkAddressSpace string
param subnetName1 string
param subnetName2 string
param subnetAddressPrefix1 string
param subnetAddressPrefix2 string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressSpace]
    }
  }
}

resource computeSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName1
  properties: {
    addressPrefix: subnetAddressPrefix1
    privateEndpointNetworkPolicies: 'Enabled'
  }
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName2
  properties: {
    addressPrefix: subnetAddressPrefix2
    privateEndpointNetworkPolicies: 'Enabled'
  }

  dependsOn: [
    computeSubnet
  ]
}

output virtualNetworkId string = virtualNetwork.id
output computeSubnet string = computeSubnet.id
output privateEndpointSubnet string = privateEndpointSubnet.id
