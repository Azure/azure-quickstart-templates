@description('The shared key used to establish connection between the two vNet Gateways.')
@secure()
param sharedKey string

@description('The SKU for the VPN Gateway. Cannot be Basic SKU.')
@allowed([
  'Standard'
  'HighPerformance'
  'VpnGw1'
  'VpnGw2'
  'VpnGw3'
])
param gatewaySku string = 'VpnGw1'

@description('Location of the resources')
param location string = resourceGroup().location

var vnet1cfg = {
  name: 'vNet1-${location}'
  addressSpacePrefix: '10.0.0.0/23'
  subnetName: 'subnet1'
  subnetPrefix: '10.0.0.0/24'
  gatewayName: 'vNet1-Gateway'
  gatewaySubnetPrefix: '10.0.1.224/27'
  gatewayPublicIPName: 'gw1pip${uniqueString(resourceGroup().id)}'
  connectionName: 'vNet1-to-vNet2'
  asn: 65010
}
var vnet2cfg = {
  name: 'vnet2-${location}'
  addressSpacePrefix: '10.0.2.0/23'
  subnetName: 'subnet1'
  subnetPrefix: '10.0.2.0/24'
  gatewayName: 'vnet2-Gateway'
  gatewaySubnetPrefix: '10.0.3.224/27'
  gatewayPublicIPName: 'gw2pip${uniqueString(resourceGroup().id)}'
  connectionName: 'vnet2-to-vnet1'
  asn: 65050
}

resource vnet1 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnet1cfg.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet1cfg.addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: vnet1cfg.subnetName
        properties: {
          addressPrefix: vnet1cfg.subnetPrefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: vnet1cfg.gatewaySubnetPrefix
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnet2cfg.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet2cfg.addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: vnet2cfg.subnetName
        properties: {
          addressPrefix: vnet2cfg.subnetPrefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: vnet2cfg.gatewaySubnetPrefix
        }
      }
    ]
  }
}

resource gw1pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vnet1cfg.gatewayPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource gw2pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vnet2cfg.gatewayPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vnet1Gateway 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: vnet1cfg.gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'vnet1GatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets',vnet1.name , 'GatewaySubnet')
          }
          publicIPAddress: {
            id: gw1pip.id
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    vpnType: 'RouteBased'
    enableBgp: true
    bgpSettings: {
      asn: vnet1cfg.asn
    }
  }
}

resource vnet2Gateway 'Microsoft.Network/virtualNetworkGateways@2020-05-01' = {
  name: vnet2cfg.gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'vNet2GatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets',vnet2.name , 'GatewaySubnet')
          }
          publicIPAddress: {
            id: gw2pip.id
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    vpnType: 'RouteBased'
    enableBgp: true
    bgpSettings: {
      asn: vnet2cfg.asn
    }
  }
}

resource vpn1to2Connection 'Microsoft.Network/connections@2020-05-01' = {
  name: vnet1cfg.connectionName
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: vnet1Gateway.id
      properties: {}
    }
    virtualNetworkGateway2: {
      id: vnet2Gateway.id
      properties: {}
    }
    connectionType: 'Vnet2Vnet'
    routingWeight: 3
    sharedKey: sharedKey
    enableBgp: true
  }
}

resource vpn2to1Connection 'Microsoft.Network/connections@2020-05-01' = {
  name: vnet2cfg.connectionName
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: vnet2Gateway.id
      properties: {}
    }
    virtualNetworkGateway2: {
      id: vnet1Gateway.id
      properties: {}
    }
    connectionType: 'Vnet2Vnet'
    routingWeight: 3
    sharedKey: sharedKey
    enableBgp: true
  }
}
