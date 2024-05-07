@description('Load Balancer name')
param slbName string = 'myLoadBalancer'

@description('Location for the resources')
param location string = resourceGroup().location

@description('OS type. Used to set the correct NAT rule destination')
@allowed([
  'ubuntulinux'
  'windowsserver'
])
param osType string = 'ubuntulinux'

var slbPIPName = '${slbName}-PIP'
var natRuleName = '${slbName}-natrule'
var natRuleBackendPort = osType == 'ubuntulinux' ? 22 : 3389
var feConfigName = 'FrontEndConfig'
var bePoolName = 'bepool01'
resource slbPIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
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
resource slb 'Microsoft.Network/loadBalancers@2023-04-01' = {
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
        name: feConfigName
      }
    ]
    backendAddressPools: [
      {
        name: bePoolName
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', slbName, feConfigName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', slbName, bePoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', slbName, 'probe01')
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
resource inboundNatRules 'Microsoft.Network/loadBalancers/inboundNatRules@2023-04-01' = {
  name: natRuleName
  parent: slb
  properties: {
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', slbName, feConfigName)
    }
    backendAddressPool: {
      id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', slbName, bePoolName)
    }
    backendPort:natRuleBackendPort
    frontendPortRangeStart:50000
    frontendPortRangeEnd:51000
    protocol:'Tcp'
    idleTimeoutInMinutes: 4
  }
}

output slbId  string = slb.id
output slbName string = slb.name
output slbFeConfigName string = slb.properties.frontendIPConfigurations[0].name
output slbBePoolName string = slb.properties.backendAddressPools[0].name
output slbBackendPoolArray array = slb.properties.backendAddressPools
output slbPublicIPAddress string = slbPIP.properties.ipAddress
