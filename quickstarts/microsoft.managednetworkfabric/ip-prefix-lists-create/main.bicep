@description('Name of the Ip Prefix Lists')
param ipPrefixListName string

@description('Azure Region for deployment of the Ip Prefix Lists and associated resources')
param location string = resourceGroup().location

@description('Action')
param action string

@description('Sequence Number')
param sequenceNumber int

@description('Network Address')
param networkAddress string

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

output resourceID string = ipPrefixLists.id
