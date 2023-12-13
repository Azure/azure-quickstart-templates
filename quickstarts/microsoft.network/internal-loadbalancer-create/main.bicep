@description('address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet prefix')
param subnetPrefix string = '10.0.0.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

var virtualNetworkName = 'myVNet'
var subnetName = 'myBackendSubnet'
var loadBalancerName = 'myLoadBalancer'
var nicName = 'myNIC1'
var lbSku = 'Standard'
var lbFrontEndName = 'loadBalancerFrontEnd'
var lbBackEndName = 'loadBalancerBackEnd'
var lbRuleName = 'HTTPRule'
var lbProbeName = 'TCPPort80HealthProbe'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetPrefix
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lb.name, lbBackEndName)
            }
          ]
        }
      }
    ]
  }
}

resource lb 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: lbSku
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndName
        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBackEndName
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadBalancerName, lbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, lbBackEndName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, lbProbeName)
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableTcpReset: true
          disableOutboundSnat: true
          idleTimeoutInMinutes: 15
        }
        name: lbRuleName
      }
    ]
    probes: [
      {
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
        name: lbProbeName
      }
    ]
  }
}
