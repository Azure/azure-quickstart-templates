@description('Required. Private DNS zone name.')
param privateDNSZoneName string

@description('Required. Network Id.')
param virtualNetworkId string

@description('Required. ASE network configuration.')
param aseNetworkConfiguration string

resource privatezone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZoneName
  location: 'global'
  properties: {}
}

resource vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privatezone
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

resource webrecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privatezone
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference(aseNetworkConfiguration, '2021-02-01').internalInboundIpAddresses[0]
      }
    ]
  }
}

resource scmrecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privatezone
  name: '*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference(aseNetworkConfiguration, '2021-02-01').internalInboundIpAddresses[0]
      }
    ]
  }
}

resource atrecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privatezone
  name: '@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference(aseNetworkConfiguration, '2021-02-01').internalInboundIpAddresses[0]
      }
    ]
  }
}
