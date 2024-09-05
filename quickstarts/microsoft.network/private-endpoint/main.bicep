@description('Location for all resources.')
param location string = resourceGroup().location

@description('Private Link resource name from same tenant or cross-tenant.')
param privateLinkResourceName string

@description('Private Link sub resource name for Private Endpoint.')
param targetSubResource array

@description('Request message for the Private Link approval.')
param requestMessage string

@description('Private Endpoint VNet Name.')
param virtualNetworkName string

@description('Private Endpoint VNet Address Space.')
param virtualNetworkAddressSpace string

@description('Private Endpoint Subnet Name.')
param subnetName string

@description('Private Endpoint Subnet Address Prefix.')
param subnetAddressPrefix string

@description('Private DNS Zone name for Private Endpoint dns integration.')
param privateDnsZoneName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: privateLinkResourceName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenant().tenantId
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressSpace]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: location
}

resource virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
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
