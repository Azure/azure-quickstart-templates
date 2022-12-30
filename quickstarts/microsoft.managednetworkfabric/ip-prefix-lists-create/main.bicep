@description('Name of the Ip Prefix Lists')
param ipPrefixListName string

@description('Azure Region for deployment of the Ip Prefix Lists and associated resources')
param location string = resourceGroup().location

var action = 'allow'
var sequenceNumber = 1234
var networkAddress = '1.1.1.0/24'

@description('Create Ip Prefix Lists Resource')
resource ipPrefixLists 'Microsoft.ManagedNetworkFabric/ipPrefixLists@2022-01-15-privatepreview' = {
  name: ipPrefixListName
  location: location
  properties: {
    action: action
    sequenceNumber: sequenceNumber
    networkAddress: networkAddress
  }
}
