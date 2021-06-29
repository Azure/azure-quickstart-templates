@description('Location for all resources.')
param location string = resourceGroup().location

@description('Virtual network name')
param virtualNetworkName string

@description('Cosmos DB account name, max length 44 characters')
param accountName string

@description('Enable public network traffic to access the account; if set to Disabled, public network traffic will be blocked even before the private endpoint is created')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Private endpoint name')
param privateEndpointName string

var accountName_var = toLower(accountName)
var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

resource virtualNetworkName_resource 'Microsoft.Network/VirtualNetworks@2020-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '172.20.0.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource accountName_resource 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: accountName_var
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    publicNetworkAccess: publicNetworkAccess
  }
}

resource privateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, 'Default')
    }
    privateLinkServiceConnections: [
      {
        name: 'MyConnection'
        properties: {
          privateLinkServiceId: accountName_resource.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkName_resource
  ]
}
