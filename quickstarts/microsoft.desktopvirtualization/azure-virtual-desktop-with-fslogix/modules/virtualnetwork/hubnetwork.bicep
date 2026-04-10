param remoteVirtualNetworkId string
param hubVirtualNetworkName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: hubVirtualNetworkName
}

resource virtualNetworkToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  parent: virtualNetwork
  name: '${hubVirtualNetworkName}-To-${split(remoteVirtualNetworkId, '/')[8]}'
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
  }
}
