param location string

param virtualNetworkName string
param virtualNetworkAddressSpace string
//param virtualNetworkPeeringToHub bool
//param hubVirtualNetworkRG string
//param hubVirtualNetworkName string
param subnetName1 string
param subnetName2 string
param subnetAddressPrefix1 string
param subnetAddressPrefix2 string

/*resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = if(virtualNetworkPeeringToHub) {
  //Set above scope to scope: az.resourceGroup(hubVirtualNetworkRG) if the hub network is in another resource group
  name: hubVirtualNetworkName
}*/

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressSpace]
    }
    //dhcpOptions: {}
    //virtualNetworkPeeringToHub ? {
    //  dnsServers: hubVirtualNetwork.properties.dhcpOptions.dnsServers
    //} : {}
  }
}

/*resource virtualNetworkToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = if(virtualNetworkPeeringToHub) {
  parent: virtualNetwork
  name: '${virtualNetwork.name}-To-${hubVirtualNetworkName}'
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(hubVirtualNetworkRG, 'Microsoft.Network/virtualNetworks', hubVirtualNetworkName)
    }
  }
}

module virtualNetworkHub 'hubnetwork.bicep' = if(virtualNetworkPeeringToHub) {
  //Set above scope to scope: az.resourceGroup(hubVirtualNetworkRG) if the hub network is in another resource group
  name: 'hubVirtualNetworkPeering'
  params: {
    remoteVirtualNetworkId: virtualNetwork.id
    hubVirtualNetworkName: hubVirtualNetworkName
  }
}*/

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName1
  properties: {
    addressPrefix: subnetAddressPrefix1
    privateEndpointNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    //virtualNetworkHub
  ]
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName2
  properties: {
    addressPrefix: subnetAddressPrefix2
    privateEndpointNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    //virtualNetworkHub
  ]
}

output virtualNetworkId string = virtualNetwork.id
output subnetId1 string = subnet1.id
output subnetId2 string = subnet2.id
