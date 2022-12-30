@description('Name of the Route Access Control Lists')
param accessControlListName string

@description('Azure Region for deployment of the Route Access Control Lists and associated resources')
param location string = resourceGroup().location

var addressFamily = 'ipv4'
var sequenceNumber = 123445
var action = 'allow'
var destinationAddress = '1.1.10.10'
var destinationPort = '1123'
var sourceAddress = '1.1.1.0/24'
var sourcePort = '1254'
var protocol = 255

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
