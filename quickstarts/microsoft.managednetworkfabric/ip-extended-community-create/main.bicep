@description('Name of the Ip Extended Community')
param ipExtendedCommunityName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string

@description('List of IP Extended Community Rules')
param ipExtendedCommunityRules array

resource ipExtendedCommunity 'Microsoft.ManagedNetworkFabric/ipExtendedCommunities@2023-06-15' = {
  name: ipExtendedCommunityName
  location: location
  properties: {
    annotation: annotation
    ipExtendedCommunityRules: ipExtendedCommunityRules
  }
}

output resourceID string = ipExtendedCommunity.id
