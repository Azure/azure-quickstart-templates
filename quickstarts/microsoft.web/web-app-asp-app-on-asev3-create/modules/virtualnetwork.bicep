@description('Required. The Virtual Network (vNet) Name.')
param virtualNetworkName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array

@description('Required. Name of the Network Security Group.')
@minLength(1)
param networkSecurityGroupName string

@description('Required. Array of Security Rules to deploy to the Network Security Group.')
param networkSecurityGroupSecurityRules array = []

@description('Required. An Array of subnets to deploy to the Virual Network.')
@minLength(1)
param subnets array

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vNetAddressPrefixes
    }
    subnets: [for item in subnets: {
      name: item.name
      properties: {
        addressPrefix: item.addressPrefix
        networkSecurityGroup: (empty(item.networkSecurityGroupName) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', item.networkSecurityGroupName)}"}'))
        delegations: item.delegations
      }
    }]
  }
  dependsOn: [
    networksecuritygroup
  ]
}

module networksecuritygroup './networksecuritygroup.bicep' = {
  name: networkSecurityGroupName
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    networkSecurityGroupSecurityRules: networkSecurityGroupSecurityRules
  }
}
