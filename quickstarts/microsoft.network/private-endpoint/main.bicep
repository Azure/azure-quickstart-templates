@description('Location for all resources.')
param location string = resourceGroup().location

@description('Private Endpoint Name.')
param privateEndpointName string

@description('Private Link resource ID from same tenant or cross-tenant.')
param privateLinkResourceId string

@description('Private Link sub resource name for Private Endpoint.')
param targetSubResource array

@description('Request message for the Private Link approval.')
param requestMessage string

@description('Private Endpoint Subnet ID.')
param subnetId string

@description('Private DNS Zone ID for Private Endpoint dns integration.')
param privateDnsZoneId string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: '${split(privateLinkResourceId, '/')[8]}-nic'
    manualPrivateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkResourceId
          groupIds: targetSubResource
          requestMessage: requestMessage
        }
      }
    ]
  }
  tags: {}
}

resource symbolicname 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: replace(split(privateDnsZoneId, '/')[8], '.', '_')
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: split(privateLinkResourceId, '/')[8]
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
