@description('Name of the Ip Prefix')
param ipPrefixName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string

@description('Ip Prefix')
param ipPrefixRules array

@description('Create Ip Prefix Resource')
resource ipPrefix 'Microsoft.ManagedNetworkFabric/ipPrefixes@2023-06-15' = {
  name: ipPrefixName
  location: location
  properties: {
    annotation: annotation
    ipPrefixRules: ipPrefixRules
  }
}

output resourceID string = ipPrefix.id
