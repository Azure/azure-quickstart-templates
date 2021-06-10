@description('The location into which the Private Link service resources should be deployed.')
param location string

@description('The resource ID of the virtual network subnet that the Private Link service should be deployed into.')
param subnetResourceId string

@description('The resource ID of the load balancer\'s frontend IP configuration that should be associated with this Private Link service.')
param loadBalancerFrontendIpConfigurationResourceId string

var privateLinkServiceName = 'MyPrivateLinkService'

resource privateLinkService 'Microsoft.Network/privateLinkServices@2020-06-01' = {
  name: privateLinkServiceName
  location: location
  properties: {
    enableProxyProtocol: false
    loadBalancerFrontendIpConfigurations: [
      {
        id: loadBalancerFrontendIpConfigurationResourceId
      }
    ]
    ipConfigurations: [
      {
        name: 'application-configuration'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: subnetResourceId
          }
          primary: false
        }
      }
    ]
  }
}

output privateLinkServiceResourceId string = privateLinkService.id
output privateLinkServiceLocation string = privateLinkService.location
