@description('Name of the Ip Community')
param ipCommunityName string

@description('Azure Region for deployment of the Ip Community and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string = ''

@description('List of IP Community Rules')
param ipCommunityRules array

@description('Create Ip Community Resource')
resource ipCommunity 'Microsoft.ManagedNetworkFabric/ipCommunities@2023-06-15' = {
  name: ipCommunityName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    ipCommunityRules: [for i in range(0, length(ipCommunityRules)): {
      action: ipCommunityRules[i].action
      sequenceNumber: ipCommunityRules[i].sequenceNumber
      wellKnownCommunities: contains(ipCommunityRules[i], 'wellKnownCommunities') ? ipCommunityRules[i].wellKnownCommunities : null
      communityMembers: ipCommunityRules[i].communityMembers
    }]
  }
}

output resourceID string = ipCommunity.id
