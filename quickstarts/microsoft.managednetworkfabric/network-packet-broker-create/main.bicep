@description('Name of Network Packet Broker Name')
param networkPacketBrokerName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('ARM resource ID of the Network Fabric')
param networkFabricId string

@description('Create Network Packet Broker Resource')
resource npb 'Microsoft.ManagedNetworkFabric/networkPacketBrokers@2023-06-15' = {
  name: networkPacketBrokerName
  location: location
  properties: {
    networkFabricId: networkFabricId
  }
}

output resourceID string = npb.id
