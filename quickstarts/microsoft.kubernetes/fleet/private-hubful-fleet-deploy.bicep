@description('The name of the vnet.')
param vnet_name string = 'myVnet'

@description('The name of the Fleet resource.')
param fleet_name string = 'my-private-fleet'

@description('The object id of Fleets Service Principal in your tenant.')
param fleets_sp_object_id string

@description('The location of the Fleet resource.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnet_name
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
  name: fleet_name
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
  name: '${vnet_name}/subnet'
  properties: {
    addressPrefix: '192.168.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    vnet
  ]
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: vnet_subnet
  name: guid(vnet_subnet.id, fleets_sp_object_id)
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4d97b98b-1d4f-4787-a291-c67834d212e7'
    )
    principalId: fleets_sp_object_id
    principalType: 'ServicePrincipal'
  }
}
