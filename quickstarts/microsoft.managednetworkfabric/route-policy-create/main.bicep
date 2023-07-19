@description('Name of the Route Policy')
param routePolicyName string

@description('Azure Region for deployment of the Route Policy and associated resources')
param location string = resourceGroup().location

@description('Route Policy statements')
param statements array

@description('Switch configuration description')
param annotation string = ''

@description('ARM Resource ID of the Network Fabric')
param networkFabricId string

@allowed([
  'IPv4'
  'IPv6'
])
@description('AddressFamilyType. This parameter decides whether the given ipv4 or ipv6 route policy')
param addressFamilyType string = 'IPv4'

@description('Create Route Policy')
resource routePolicies 'Microsoft.ManagedNetworkFabric/routePolicies@2023-06-15' = {
  name: routePolicyName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    networkFabricId: networkFabricId
    addressFamilyType: addressFamilyType
    statements: [for i in range(0, length(statements)): {
      sequenceNumber: statements[i].sequenceNumber
      condition: {
        ipCommunityIds: contains(statements[i].condition, 'ipCommunityIds') ? statements[i].condition.ipCommunityIds : null
        ipExtendedCommunityIds: contains(statements[i].condition, 'ipExtendedCommunityIds') ? statements[i].condition.ipExtendedCommunityIds : null
        ipPrefixId: contains(statements[i].condition, 'ipPrefixId') ? statements[i].condition.ipPrefixId : null
        type: contains(statements[i].condition, 'type') ? statements[i].condition.type : null
      }
      action: {
        localPreference: contains(statements[i].action, 'localPreference') ? statements[i].action.localPreference : null
        actionType: statements[i].action.actionType
        ipCommunityProperties: contains(statements[i].action, 'ipCommunityProperties') ? {
          add: contains(statements[i].action.ipCommunityProperties, 'add') ? {
            ipCommunityIds: contains(statements[i].action.ipCommunityProperties.add, 'ipCommunityIds') ? statements[i].action.ipCommunityProperties.add.ipCommunityIds : null
          } : null
          delete: contains(statements[i].action.ipCommunityProperties, 'delete') ? {
            ipCommunityIds: contains(statements[i].action.ipCommunityProperties.delete, 'ipCommunityIds') ? statements[i].action.ipCommunityProperties.delete.ipCommunityIds : null
          } : null
          set: contains(statements[i].action.ipCommunityProperties, 'set') ? {
            ipCommunityIds: contains(statements[i].action.ipCommunityProperties.set, 'ipCommunityIds') ? statements[i].action.ipCommunityProperties.set.ipCommunityIds : null
          } : null
        } : null
        ipExtendedCommunityProperties: contains(statements[i].action, 'ipExtendedCommunityProperties') ? {
          add: contains(statements[i].action.ipExtendedCommunityProperties, 'add') ? {
            ipExtendedCommunityIds: contains(statements[i].action.ipExtendedCommunityProperties.add, 'ipExtendedCommunityIds') ? statements[i].action.ipExtendedCommunityProperties.add.ipExtendedCommunityIds : null
          } : null
          delete: contains(statements[i].action.ipExtendedCommunityProperties, 'delete') ? {
            ipExtendedCommunityIds: contains(statements[i].action.ipExtendedCommunityProperties.delete, 'ipExtendedCommunityIds') ? statements[i].action.ipExtendedCommunityProperties.delete.ipExtendedCommunityIds : null
          } : null
          set: contains(statements[i].action.ipExtendedCommunityProperties, 'set') ? {
            ipExtendedCommunityIds: contains(statements[i].action.ipExtendedCommunityProperties.set, 'ipExtendedCommunityIds') ? statements[i].action.ipExtendedCommunityProperties.set.ipExtendedCommunityIds : null
          } : null
        } : null
      }
    }]
  }
}

output resourceID string = routePolicies.id
