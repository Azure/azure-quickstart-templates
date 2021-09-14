@description('Required. ASE name.')
param aseName string

@description('Required. Private DNS zone name.')
param privateDNSZoneName string

@description('Required. Network Id.')
param virtualNetworkId string

resource aseConfig 'Microsoft.Web/hostingEnvironments/configurations@2021-01-15' existing = {
  name: '${aseName}/networking'
  }

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
        ipv4Address: aseConfig.properties.internalInboundIpAddresses[0]
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
        ipv4Address: aseConfig.properties.internalInboundIpAddresses[0]
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
        ipv4Address: aseConfig.properties.internalInboundIpAddresses[0]
      }
    ]
  }
}
