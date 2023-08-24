param vWANhubs array

resource hub1SpokeVnet1 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vWANhubs[0].spoke1.name
  location: vWANhubs[0].location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vWANhubs[0].spoke1.addressSpace
      ]
    }
    enableDdosProtection: false
  }
}

resource hub1SpokeVnet2 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vWANhubs[0].spoke2.name
  location: vWANhubs[0].location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vWANhubs[0].spoke2.addressSpace
      ]
    }
    enableDdosProtection: false
  }
}

resource hub2SpokeVnet1 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vWANhubs[1].spoke1.name
  location: vWANhubs[1].location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vWANhubs[1].spoke1.addressSpace
      ]
    }
    enableDdosProtection: false
  }
}

resource hub2SpokeVnet2 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vWANhubs[1].spoke2.name
  location: vWANhubs[1].location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vWANhubs[1].spoke2.addressSpace
      ]
    }
    enableDdosProtection: false
  }
}

resource hub1SpokeVnet1Subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: hub1SpokeVnet1
  name: '${vWANhubs[0].spoke1.name}-subnet'
  properties: {
    addressPrefix: vWANhubs[0].spoke1.addressSpace
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  } 
}

resource hub1SpokeVnet2Subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: hub1SpokeVnet2
  name: '${vWANhubs[0].spoke2.name}-subnet'
  properties: {
    addressPrefix: vWANhubs[0].spoke2.addressSpace
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  } 
}

resource hub2SpokeVnet1Subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: hub2SpokeVnet1
  name: '${vWANhubs[1].spoke1.name}-subnet'
  properties: {
    addressPrefix: vWANhubs[1].spoke1.addressSpace 
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource hub2SpokeVnet2Subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: hub2SpokeVnet2
  name: '${vWANhubs[1].spoke2.name}-subnet'
  properties: {
    addressPrefix: vWANhubs[1].spoke2.addressSpace
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output spokeVnetsIDs array = [
  hub1SpokeVnet1.id
  hub1SpokeVnet2.id
  hub2SpokeVnet1.id
  hub2SpokeVnet2.id
]
