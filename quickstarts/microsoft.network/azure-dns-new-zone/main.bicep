@description('The name of the DNS zone to be created.  Must have at least 2 segments, e.g. hostname.org')
param zoneName string = '${uniqueString(resourceGroup().id)}.azurequickstart.org'

@description('The name of the DNS record to be created.  The name is relative to the zone, not the FQDN.')
param recordName string = 'www'

resource zone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: zoneName
  location: 'global'
}

resource record 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  parent: zone
  name: recordName
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: '1.2.3.4'
      }
      {
        ipv4Address: '1.2.3.5'
      }
    ]
  }
}

output nameServers array = zone.properties.nameServers
