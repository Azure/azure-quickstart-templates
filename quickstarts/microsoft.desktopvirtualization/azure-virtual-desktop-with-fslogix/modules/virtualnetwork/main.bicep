@description('Location for all resources.')
param location string

@description('Virtual network resource name.')
param virtualNetworkName string
@description('Virtual network resource Address Space.')
param virtualNetworkAddressSpace string
@description('Peer Virtual network with Hub network')
param virtualNetworkPeeringToHub bool
@description('Hub Virtual network RG')
param hubVirtualNetworkRG string
@description('Hub Virtual network name')
param hubVirtualNetworkName string
@description('Virtual network resource Subnet 1 name.')
param subnetName1 string
@description('Virtual network resource Subnet 2 name.')
param subnetName2 string
@description('Virtual network resource Subnet 1 Address Prefix.')
param subnetAddressPrefix1 string
@description('Virtual network resource Subnet 2 Address Prefix.')
param subnetAddressPrefix2 string

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = if(virtualNetworkPeeringToHub) {
  scope: az.resourceGroup(hubVirtualNetworkRG)
  name: hubVirtualNetworkName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressSpace]
    }
    dhcpOptions: virtualNetworkPeeringToHub ? {
      dnsServers: hubVirtualNetwork.properties.dhcpOptions.dnsServers
    } : {}
  }
}

resource virtualNetworkToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = if(virtualNetworkPeeringToHub) {
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
  scope: az.resourceGroup(hubVirtualNetworkRG)
  name: 'virtualNetworkPeeringToHub'
  params: {
    remoteVirtualNetworkId: virtualNetwork.id
    hubVirtualNetworkName: hubVirtualNetworkName
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName1
  properties: {
    addressPrefix: subnetAddressPrefix1
    privateEndpointNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworkHub
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
    virtualNetworkHub
  ]
}

output virtualNetworkId string = virtualNetwork.id
output subnetId1 string = subnet1.id
output subnetId2 string = subnet2.id
