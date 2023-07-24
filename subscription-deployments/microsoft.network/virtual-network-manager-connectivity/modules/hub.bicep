param location string
param connectivityTopology string

@description('The regional hub network.')
resource vnetHub 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet-${location}-hub'
  location: location
  // add tag to include hub vnet in the connected group mesh only when connectivity topology is 'mesh'
  tags: (connectivityTopology == 'mesh') ? {
    _avnm_quickstart_deployment: 'hub'
  } : {}
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.2.0/27'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.3.0/26'
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: '10.0.3.64/26'
        }
      }
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.3.128/25'
        }
      }
    ]
  }
}

output hubVnetId string = vnetHub.id
