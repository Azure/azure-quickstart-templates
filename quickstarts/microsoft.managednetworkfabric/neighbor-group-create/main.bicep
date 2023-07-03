@description('Name of Neighbor Group Name')
param neighborGroupName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string

@description('An array of destination IPv4 Addresses or IPv6 Addresses')
param destination object

@description('Create Neighbor Group Resource')
resource neighborGroup 'Microsoft.ManagedNetworkFabric/neighborGroups@2023-06-15' = {
  name: neighborGroupName
  location: location
  properties: {
    annotation: annotation
    destination: destination
  }
}

output resourceID string = neighborGroup.id
