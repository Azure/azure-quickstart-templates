@description('Name of Network Tap Name')
param networkTapName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string

@description('ARM resource ID of the Network Packet Broker')
param networkPacketBrokerId string

@description('Polling type')
@allowed([
  'Pull'
  'Push'
])
param pollingType string

@description('List of destinations to send the filter traffic.')
param destinations object

@description('Create Network Tap Resource')
resource tap 'Microsoft.ManagedNetworkFabric/networkTaps@2023-06-15' = {
  name: networkTapName
  location: location
  properties: {
    annotation: annotation
    networkPacketBrokerId: networkPacketBrokerId
    pollingType: pollingType
    destinations: destinations
  }
}

output resourceID string = tap.id
