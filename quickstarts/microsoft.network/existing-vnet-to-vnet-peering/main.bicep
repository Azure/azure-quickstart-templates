@description('Set the vmnet 1')
param vmnetName1 string

@description('Set the vmnet 2')
param vmnetName2 string

@description('Sets the vmnet 1 resource group')
param vmnet1RG string

@description('Sets the vmnet 2 resource group')
param vmnet2RG string

resource vmnet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${vmnetName1}/peering-to-${vmnetName2}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(vmnet2RG, 'Microsoft.Network/virtualNetworks', vmnetName2)
    }
  }
}

resource vmnet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${vmnetName2}/peering-to-${vmnetName1}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(vmnet1RG, 'Microsoft.Network/virtualNetworks', vmnetName1)
    }
  }
}
