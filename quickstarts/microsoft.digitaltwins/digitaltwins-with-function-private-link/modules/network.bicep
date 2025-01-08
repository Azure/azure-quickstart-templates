@description('Virtual Network Name')
param virtualNetworkName string

@description('Virtual Network location')
param virtualNetworkLocation string

@description('Virtual Network address prefix')
param virtualNetworkAddressPrefix string

@description('Function Subnet Name')
param functionSubnetName string

@description('Function Subnet address prefix')
param functionSubnetPrefix string

@description('PrivateLink Subnet Name')
param privateLinkSubnetName string

@description('PrivateLink Subnet address prefix')
param privateLinkSubnetPrefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: virtualNetworkName
  location: virtualNetworkLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: functionSubnetName
        properties: {
          addressPrefix: functionSubnetPrefix
          delegations: [
            {
              name: 'webapp'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: privateLinkSubnetName
        properties: {
          addressPrefix: privateLinkSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}
