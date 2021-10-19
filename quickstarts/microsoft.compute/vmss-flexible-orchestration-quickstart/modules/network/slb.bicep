@description('Load Balancer name')
param slbName string = 'myLoadBalancer'

@description('Location for the resources')
param location string = resourceGroup().location

var slbPIPName = '${slbName}-PIP'
resource slbPIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: slbPIPName
  location: location
  sku:{
    tier: 'Regional'
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}
resource slb 'Microsoft.Network/loadBalancers@2021-02-01' = {
  name: slbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: slbPIP.id
          }
        }
        name: 'FrontEndConfig'
      }
    ]
    backendAddressPools: [
      {
        name: 'bepool01'
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', slbName, 'FrontEndConfig')}'
          }
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/loadBalancers/backendAddressPools', slbName, 'bepool01')}'
          }
          probe: {
            id: '${resourceId('Microsoft.Network/loadBalancers/probes', slbName, 'probe01')}'
          }
          protocol: 'Tcp'
          loadDistribution: 'Default'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 4
          enableFloatingIP: false
          enableTcpReset: false
          disableOutboundSnat: false
        }
        name: 'string'
      }
    ]
    probes: [
      {
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
        name: 'probe01'
      }
    ]
  }
}
output slbId  string = slb.id
output slbName string = slb.name
output slbFeConfigName string = slb.properties.frontendIPConfigurations[0].name
output slbBePoolName string = slb.properties.backendAddressPools[0].name
output slbBackendPoolArray array = slb.properties.backendAddressPools
output slbPublicIPAddress string = slbPIP.properties.ipAddress
