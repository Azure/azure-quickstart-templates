@description('Location for all resources.')
param location string = resourceGroup().location

@description('Private Link resource name from same tenant or cross-tenant.')
param privateLinkResourceName string

@description('Private Link sub resource name for Private Endpoint.')
param targetSubResource array

@description('Request message for the Private Link approval.')
param requestMessage string

@description('Private Endpoint VNet RG Name.')
param virtualNetworkRG string

@description('Private Endpoint VNet Name.')
param virtualNetworkName string

@description('Private Endpoint Subnet Name.')
param subnetName string

@description('Private DNS Zone name for Private Endpoint dns integration.')
param privateDnsZoneName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: privateLinkResourceName
  scope: resourceGroup(virtualNetworkRG )
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  scope: resourceGroup(virtualNetworkRG)
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  parent: virtualNetwork
  name: subnetName
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
  scope: resourceGroup(virtualNetworkRG )
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  location: location
  name: '${privateLinkResourceName}-pe'
  properties: {
    subnet: {
      id: subnet.id
    }
    customNetworkInterfaceName: '${split(keyVault.id, '/')[8]}-nic'
    manualPrivateLinkServiceConnections: [
      {
        name: '${privateLinkResourceName}-pe'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: targetSubResource
          requestMessage: requestMessage
        }
      }
    ]
  }
  tags: {}
}

resource symbolicname 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: replace(privateDnsZoneName, '.', '_')
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: split(keyVault.id, '/')[8]
        properties: {
          privateDnsZoneId: privateDNSZone.id
        }
      }
    ]
  }
}
