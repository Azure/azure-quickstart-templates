param location string

@description('Virtual network resource name.')
param virtualNetworkName string

@description('Virtual network resource Address Space.')
param virtualNetworkAddressSpace array

@description('Virtual network resource Subnet name.')
param subnetName1 string
param subnetName2 string

@description('Virtual network resource Subnet Address Prefix.')
param subnetAddressPrefix1 string
param subnetAddressPrefix2 string

param kubernetesPrincipalId string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressSpace
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName1
  properties: {
    addressPrefix: subnetAddressPrefix1
    privateEndpointNetworkPolicies: 'Enabled'
  }
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName2
  properties: {
    addressPrefix: subnetAddressPrefix2
    privateEndpointNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    subnet1
  ]
}

resource aksRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  scope: subscription()
}

resource aksRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, virtualNetwork.id)
  scope: virtualNetwork
  properties: {
    principalId: kubernetesPrincipalId
    roleDefinitionId: aksRoleDefinition.id//'7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

output virtualNetworkObject object = virtualNetwork
output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output subnet1Id string = subnet1.id
output subnet2Id string = subnet2.id
