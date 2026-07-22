@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

@description('Required. The name of the Virtual Network to create.')
param virtualNetworkName string

@description('Required. The name of the Virtual Network to create.')
param addressPrefix string = '10.1.0.0/16'

param mainSubnetAddressPrefix string = cidrSubnet(addressPrefix, 24, 1)

@description('Optional. The network security rules to use in the network security group associated with the main subnet.')
param networkSecurityRules array

@description('Tags to apply on the resources.')
param tags object

module nsg_subnet_main 'br/public:avm/res/network/network-security-group:0.5.2' = {
  name: 'nsg-subnet-main-deployment'
  params: {
    name: 'nsg-subnet-main'
    location: location
    securityRules: networkSecurityRules
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.1' = {
  name: '${virtualNetworkName}-module-avm'
  params: {
    addressPrefixes: [
      addressPrefix
    ]
    name: virtualNetworkName
    location: location
    tags: tags
    subnets: [
      {
        addressPrefix: mainSubnetAddressPrefix
        name: 'mainSubnet'
        defaultOutboundAccess: false
        networkSecurityGroupResourceId: nsg_subnet_main.outputs.resourceId
      }
    ]
  }
}

@description('The name of the virtual network.')
output vnetName string = virtualNetwork.outputs.name
@description('The resource ID of the virtual network.')
output vnetResourceId string = virtualNetwork.outputs.resourceId
@description('The resource ID of the main subnet.')
output mainSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[0]
