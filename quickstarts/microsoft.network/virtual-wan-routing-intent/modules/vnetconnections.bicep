param vWANhubs array
param vNetsIDs array

resource vWANHub1 'Microsoft.Network/virtualHubs@2022-11-01' existing = {
  name: vWANhubs[0].name
}

resource hub1VNet1Connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-04-01' = {
  parent: vWANHub1
name: '${vWANhubs[0].name}-to-${vWANhubs[0].spoke1.name}-connection'
  properties: {
    remoteVirtualNetwork: {
      id: vNetsIDs[0]
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
}

resource hub1VNet2Connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-04-01' = {
  parent: vWANHub1
  name: '${vWANhubs[0].name}-to-${vWANhubs[0].spoke2.name}-connection'
  properties: {
    remoteVirtualNetwork: {
      id: vNetsIDs[1]
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
}

resource vWANHub2 'Microsoft.Network/virtualHubs@2023-04-01' existing = {
  name: vWANhubs[1].name
}

resource hub2VNet1Connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-04-01' = {
  parent: vWANHub2
  name: '${vWANhubs[1].name}-to-${vWANhubs[1].spoke1.name}-connection'
  properties: {
    remoteVirtualNetwork: {
      id: vNetsIDs[2]
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
}

resource hub2VNet2Connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-04-01' = {
  parent: vWANHub2
  name: '${vWANhubs[1].name}-to-${vWANhubs[1].spoke2.name}-connection'
  properties: {
    remoteVirtualNetwork: {
      id: vNetsIDs[3] 
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
}
