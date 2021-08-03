param location string
param subnetId string
param vnetId string
param storageAccountId string
param privateEndpointName string = 'privateEndpoint${uniqueString(resourceGroup().name)}'
param privateLinkConnectionName string = 'privateLink${uniqueString(resourceGroup().name)}'
param privateDNSZoneName string = 'privatelink.file.core.windows.net'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }

  resource privateDNSZoneGroup 'privateDnsZoneGroups' = {
    name: 'dnsgroupname'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config1'
          properties: {
            privateDnsZoneId: privateDNSZone.id
          }
        }
      ]
    }
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZoneName
  location: 'global'

  resource virtualNetworkLink 'virtualNetworkLinks' = {
    name: '${privateDNSZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}
