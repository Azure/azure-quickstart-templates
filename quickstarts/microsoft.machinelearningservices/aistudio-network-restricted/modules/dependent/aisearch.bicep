@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the Azure Cognitive Search service')
param searchServiceName string

@description('Name of the private link endpoint for the search service')
param searchPrivateLinkName string

@description('Resource ID of the subnet')
param subnetId string

@description('Resource ID of the virtual network')
param virtualNetworkId string

@description('Search SKU')
@allowed([
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
param searchSkuName string = 'standard'

var searchPrivateDnsZoneName = 'privatelink.search.windows.net'

resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: searchServiceName
  location: location
  tags: tags
  sku: {
    name: searchSkuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    authOptions: { 
      aadOrApiKey: { 
        aadAuthFailureMode: 'http403'
      }
    }
    hostingMode: 'default'
    partitionCount: 1
    replicaCount: 1
    networkRuleSet: {
      ipRules: []
      bypass: 'AzureServices'
    }
    publicNetworkAccess: 'disabled'
  }
}

resource searchPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: searchPrivateLinkName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: searchPrivateLinkName
        properties: {
          groupIds: [
            'searchService'
          ]
          privateLinkServiceId: searchService.id
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource searchPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: searchPrivateDnsZoneName
  location: 'global'
}

resource searchPrivateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: searchPrivateEndpoint
  name: 'search-PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: searchPrivateDnsZoneName
        properties: {
          privateDnsZoneId: searchPrivateDnsZone.id
        }
      }
    ]
  }
}

resource searchPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: searchPrivateDnsZone
  name: uniqueString(searchService.id)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

output searchServiceId string = searchService.id
output searchServicePrincipalId string = searchService.identity.principalId
output searchServiceName string = searchService.name
output searchServiceEndpoint string = 'https://${searchServiceName}.search.windows.net'
