@description('Name of the Route Access Control Lists')
param accessControlListName string

@description('Azure Region for deployment of the Route Access Control Lists and associated resources')
param location string = resourceGroup().location

@description('IP address family')
param addressFamily string

@description('Sequence Number')
param sequenceNumber int

@description('Action')
param action string

@description('Destination Address')
param destinationAddress string

@description('Destination Port')
param destinationPort string

@description('Source Address')
param sourceAddress string

@description('Source Port')
param sourcePort string

@description('Protocol')
param protocol int

@description('Create Route Access Control Lists Resource')
resource accessControlLists 'Microsoft.ManagedNetworkFabric/accessControlLists@2022-01-15-privatepreview' = {
  name: accessControlListName
  location: location
  properties: {
    addressFamily: addressFamily
    conditions: [
      {
        sequenceNumber: sequenceNumber
        action: action
        destinationAddress: destinationAddress
        destinationPort: destinationPort
        sourceAddress: sourceAddress
        sourcePort: sourcePort
        protocol: protocol
      }
    ]
  }
}

output resourceID string = accessControlLists.id
