param virtualNetworkId string

resource privatelink_blob_core_windows_net_virtualNetworkId 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: 'privatelink.blob.core.windows.net/${uniqueString(virtualNetworkId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

resource privatelink_file_core_windows_net_virtualNetworkId 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: 'privatelink.file.core.windows.net/${uniqueString(virtualNetworkId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}
