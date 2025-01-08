@description('The location into which the load balancer resources should be deployed.')
param location string

@description('The resource ID of the virtual network subnet that the load balancer should be deployed into.')
param subnetResourceId string

var loadBalancerName = 'MyLoadBalancer'
var frontendIPConfigurationName = 'MyFrontendIPConfiguration'
var healthProbeName = 'MyHealthProbe'
var backendAddressPoolName = 'MyBackendAddressPool'

resource loadBalancer 'Microsoft.Network/loadBalancers@2020-06-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendIPConfigurationName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
      }
    ]
    probes: [
      {
        name: healthProbeName
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'HttpRule'
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 15
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, frontendIPConfigurationName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendAddressPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, healthProbeName)
          }
        }
      }
    ]
  }
}

output frontendIPAddress string = loadBalancer.properties.frontendIPConfigurations[0].properties.privateIPAddress
output frontendIPConfigurationResourceId string = resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, frontendIPConfigurationName)
output backendAddressPoolResourceId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendAddressPoolName)
