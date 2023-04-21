@description('PrivateLink location')
param location string

@description('PrivateLink name')
param privateLinkName string

@description('The PrivateLink zone name for Digital Twins')
param privateDnsZoneName string

@description('Virtual Network resource name')
param virtualNetworkResourceName string

@description('PrivateLink Subnet Name')
param privateLinkSubnetName string

@description('ResourceId of the service PrivateLink is connecting to')
param privateLinkServiceResourceId string

@description('Group Id of the service PrivateLink is connecting to')
param groupId string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: virtualNetworkResourceName
}

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource dnszonelink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: dnszone
  name: '${dnszone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privatelink 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: privateLinkName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, privateLinkSubnetName)
    }
    privateLinkServiceConnections: [
      {
        name: 'privatelinkconnection'
        properties: {
          privateLinkServiceId: privateLinkServiceResourceId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
}

resource privatednszonegroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  parent: privatelink
  name: 'privateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: dnszone.id
        }
      }
    ]
  }
}
