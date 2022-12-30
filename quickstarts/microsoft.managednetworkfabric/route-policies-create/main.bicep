@description('Name of the Route Policy')
param routePolicyName string

@description('Azure Region for deployment of the Route Policy and associated resources')
param location string = resourceGroup().location

var routeDescription = 'description of Route Policy'
var sequenceNumber = 123456

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
          accessControlListIds: [ 'asdfg123' ]
          ipCommunityListIds: [ 'qwe432' ]
          ipPrefixListIds: [ 'cdw243' ]
        }
      }
    ]
  }
}
