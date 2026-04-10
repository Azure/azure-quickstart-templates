@description('The name of the vnet.')
param vnetName string = 'myVnet'

@description('The name of the Fleet resource.')
param fleetName string = 'my-private-fleet'

@description('The object id of Fleets Service Principal in your tenant.')
param fleetSpObjectId string = '00000000-0000-0000-0000-000000000000' // Replace with the actual object ID of the Fleets Service Principal

@description('The location of the Fleet resource.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
  }
}

resource hubful_private_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleetName
  location: location
  properties: {
    hubProfile: {
      agentProfile: {
        subnetId: vnet_subnet.id
      }
      apiServerAccessProfile: {
        enablePrivateCluster: true
        enableVnetIntegration: false
      }
    }
  }
  dependsOn: [
    roleassignment
  ]
}

resource vnet_subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: 'subnet'
  properties: {
    addressPrefix: '192.168.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  parent: vnet
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: vnet_subnet
  name: guid(vnet_subnet.id, fleetSpObjectId)
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4d97b98b-1d4f-4787-a291-c67834d212e7'
    )
    principalId: fleetSpObjectId
    principalType: 'ServicePrincipal'
  }
}
