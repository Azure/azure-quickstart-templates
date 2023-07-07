@description('Name of Network Tap Name')
param networkTapName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string = ''

@description('ARM resource ID of the Network Packet Broker')
param networkPacketBrokerId string

@description('Polling type')
@allowed([
  'Pull'
  'Push'
])
param pollingType string = 'Pull'

@description('List of destinations to send the filter traffic.')
param destinations array

@description('Create Network Tap Resource')
resource tap 'Microsoft.ManagedNetworkFabric/networkTaps@2023-06-15' = {
  name: networkTapName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    networkPacketBrokerId: networkPacketBrokerId
    pollingType: pollingType
    destinations: [for i in range(0, length(destinations)): {
      name: destinations[i].name
      destinationType: destinations[i].destinationType
      destinationId: destinations[i].destinationId
      isolationDomainProperties: contains(destinations[i], 'isolationDomainProperties') ? {
        encapsulation: contains(destinations[i].isolationDomainProperties, 'encapsulation') ? destinations[i].isolationDomainProperties.encapsulation : null
        neighborGroupIds: contains(destinations[i].isolationDomainProperties, 'neighborGroupIds') ? destinations[i].isolationDomainProperties.neighborGroupIds : null
      } : null
      destinationTapRuleId: contains(destinations[i], 'destinationTapRuleId') ? destinations[i].destinationTapRuleId : null
    }]
  }
}

output resourceID string = tap.id
