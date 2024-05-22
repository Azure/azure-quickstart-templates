param virtualNetworkId string

resource privatelink_api_azureml_ms_virtualNetworkId 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: 'privatelink.api.azureml.ms/${uniqueString(virtualNetworkId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

resource privatelink_notebooks_azure_net_virtualNetworkId 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: 'privatelink.notebooks.azure.net/${uniqueString(virtualNetworkId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}
