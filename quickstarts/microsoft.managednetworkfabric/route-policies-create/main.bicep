@description('Name of the Route Policy')
param routePolicyName string

@description('Azure Region for deployment of the Route Policy and associated resources')
param location string = resourceGroup().location

@description('Description of the Route Policy')
param routeDescription string

@description('Sequence Number of the Route Policy')
param sequenceNumber int

@description('Resource Ids of accessControlListIds')
param accessControlListIds array

@description('Resource Ids of ipCommunityListIds')
param ipCommunityListIds array

@description('Resource Ids of ipPrefixListIds')
param ipPrefixListIds array

@description('Create Route Policy')
resource routePolicies 'Microsoft.ManagedNetworkFabric/routePolicies@2022-01-15-privatepreview' = {
  name: routePolicyName
  location: location
  properties: {
    description: routeDescription
    conditions: [
      {
        sequenceNumber: sequenceNumber
        match: {
          accessControlListIds: accessControlListIds
          ipCommunityListIds: ipCommunityListIds
          ipPrefixListIds: ipPrefixListIds
        }
        action: {
          set: {
            set: {
              ipCommunityListIds: accessControlListIds
            }
          }
        }
      }
    ]
  }
}

output resourceID string = routePolicies.id
