@description('The public DNS zone name.')
param dnsZoneName string = 'tm-linked-${uniqueString(resourceGroup().id)}.example.com'

@description('The relative record name. Use @ for the zone apex.')
param recordName string = 'www'

@description('The Traffic Manager profile name.')
param trafficManagerProfileName string = 'tm-linked-profile'

@description('A globally unique relative DNS name for the Traffic Manager profile.')
param trafficManagerDnsName string = 'tm-linked-${uniqueString(resourceGroup().id)}'

@description('The public IPv4 address of the primary endpoint.')
param endpoint1IpAddress string

@description('The public IPv4 address of the secondary endpoint.')
param endpoint2IpAddress string

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: 'global'
}

resource trafficManagerProfile 'Microsoft.Network/trafficManagerProfiles@2024-04-01-preview' = {
  name: trafficManagerProfileName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    recordType: 'A'
    dnsConfig: {
      relativeName: trafficManagerDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
      intervalInSeconds: 30
      timeoutInSeconds: 10
      toleratedNumberOfFailures: 3
    }
    endpoints: [
      {
        name: 'primary-endpoint'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          target: endpoint1IpAddress
          priority: 1
        }
      }
      {
        name: 'secondary-endpoint'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          target: endpoint2IpAddress
          priority: 2
        }
      }
    ]
  }
}

resource linkedRecord 'Microsoft.Network/dnsZones/A@2023-07-01-preview' = {
  parent: dnsZone
  name: recordName
  properties: {
    TTL: 30
    trafficManagementProfile: {
      id: trafficManagerProfile.id
    }
  }
}

output dnsZoneNameServers array = dnsZone.properties.nameServers
output linkedRecordResourceId string = linkedRecord.id
output trafficManagerProfileResourceId string = trafficManagerProfile.id
