@description('The name of the community endpoint.')
param communityEndpointName string

@description('The name of the community.')
param communityName string

@description('The location for the community endpoint.')
param location string

@description('The rule collection for the community endpoint.')
param ruleCollection array

@description('The metadata for the community endpoint.')
param tags object = {}

resource community 'Microsoft.Mission/communities@2026-03-01-preview' existing = {
  name: communityName
}

resource communityEndpoint 'Microsoft.Mission/communities/communityEndpoints@2026-03-01-preview' = {
  parent: community
  name: communityEndpointName
  location: location
  tags: tags
  properties: {
    ruleCollection: ruleCollection
  }
}

output communityResourceId string = community.id
output communityEndpointResourceId string = communityEndpoint.id
