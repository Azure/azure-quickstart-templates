@description('Location for all resources.')
param location string = resourceGroup().location

@description('Virtual network name')
param virtualNetworkName string
@description('Virtual network address prefix')
param virtualNetworkPrefix string
@description('Subnet name')
param subnetName string
@description('Subnet prefix')
param subnetPrefix string

@description('Load balancer name')
param loadBalancerName string = 'loadBalancer-${uniqueString(subscription().id)}'
@description('Load balancer sku')
param lbsku string = 'Standard'
@description('Load balancer rule name')
param lbrulename string = '${loadBalancerName}-HARule'
@description('Load balancer probe name')
param lbprobename string = '${loadBalancerName}HealthProbe'
@description('Load balancer backend pool network interface name')
param networkInterfaceName string = 'networkInterface1'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: virtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetPrefix
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2024-01-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: lbsku
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'loadBalancerFrontEnd'
        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'loadBalancerBackEnd'
      }
    ]
    loadBalancingRules: [
      {
        name: lbrulename
        properties: {
          frontendIPConfiguration: {
            id: resourceId( 'Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, 'loadBalancerFrontEnd')
          }
          backendAddressPool: {
            id: resourceId( 'Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'loadBalancerBackEnd')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, lbprobename)
          }
          protocol: 'All'
          frontendPort: 0
          backendPort: 0
          enableFloatingIP: false
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          idleTimeoutInMinutes: 15
        }
      }
    ]
    probes: [
      {
        name: lbprobename
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancer.properties.backendAddressPools[0].id
            }
          ]
        }
      }
    ]
  }
}
