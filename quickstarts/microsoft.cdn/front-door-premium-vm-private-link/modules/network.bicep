@description('The location into which the virtual network resources should be deployed.')
param location string

@description('The IP address prefix (CIDR range) to use when deploying the virtual network.')
param vnetIPPrefix string

@description('The IP address prefix (CIDR range) to use when deploying the VM subnet within the virtual network.')
param vmSubnetIPPrefix string

@description('The IP address prefix (CIDR range) to use when deploying the Private Link service environment subnet within the virtual network.')
param privateLinkServiceSubnetIPPrefix string

var vnetName = 'VNet'
var vmSubnetName = 'VMs'
var privateLinkServiceSubnetName = 'PrivateLinkService'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIPPrefix
      ]
    }
    subnets: [
      {
        name: vmSubnetName
        properties: {
          addressPrefix: vmSubnetIPPrefix
        }
      }
      {
        name: privateLinkServiceSubnetName
        properties: {
          addressPrefix: privateLinkServiceSubnetIPPrefix
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output vnetName string = vnetName
output vmSubnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vmSubnetName)
output privateLinkServiceSubnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateLinkServiceSubnetName)
