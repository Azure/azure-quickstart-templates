param aiServicesName string 
param aiSearchName string 
param storageName string
param vnetName string
param cxSubnetName string
param suffix string
param aiStorageId string

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
  scope: resourceGroup()
}

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiSearchName
  scope: resourceGroup()
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup()
}

resource cxSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: cxSubnetName
}

resource aiServicesPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${aiServicesName}-private-endpoint'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: cxSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${aiServicesName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: aiServices.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

resource aiSearchPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${aiSearchName}-private-endpoint'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: cxSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${aiSearchName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: aiSearch.id
          groupIds: [
            'searchService'
          ]
        }
      }
    ]
  }
}

resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${storageName}-private-endpoint'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: cxSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${storageName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: aiStorageId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource aiServicesPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azureml.ms'
  location: 'global'
}

resource aiServicesLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: aiServicesPrivateDnsZone
  location: 'global'
  name: 'aiServices-${suffix}-link'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

resource aiServicesDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: aiServicesPrivateEndpoint
  name: '${aiServicesName}-dns-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${aiServicesName}-dns-config'
        properties: {
          privateDnsZoneId: aiServicesPrivateDnsZone.id
        }
      }
    ]
  }
}

resource aiSearchPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.search.windows.net'
  location: 'global'
}

resource aiSearchLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: aiSearchPrivateDnsZone
  location: 'global'
  name: 'aiSearch-${suffix}-link'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

resource aiSearchDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: aiSearchPrivateEndpoint
  name: '${aiSearchName}-dns-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${aiSearchName}-dns-config'
        properties: {
          privateDnsZoneId: aiSearchPrivateDnsZone.id
        }
      }
    ]
  }
}

resource storagePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

resource storageLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: storagePrivateDnsZone
  location: 'global'
  name: 'storage-${suffix}-link'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}


resource storageDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: storagePrivateEndpoint
  name: '${storageName}-dns-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${storageName}-dns-config'
        properties: {
          privateDnsZoneId: storagePrivateDnsZone.id
        }
      }
    ]
  }
}
