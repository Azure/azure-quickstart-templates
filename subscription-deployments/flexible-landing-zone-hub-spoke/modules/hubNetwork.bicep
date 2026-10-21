targetScope = 'resourceGroup'

param prefix string
param location string
param tags object
param hubVnetName string
param hubAddressSpace string = '10.0.0.0/16'

param hubSubnetCidrs object = {
  firewall: '10.0.0.0/24'
  gateway: '10.0.1.0/24'
  bastion: '10.0.2.0/26'
  dns: '10.0.3.0/24'
  management: '10.0.4.0/24'
}

param enableFirewall bool = false
param enableBastion bool = false
param enableVpnGateway bool = false

@allowed([
  'Standard'
  'Premium'
])
param firewallTier string = 'Standard'

@allowed([
  'Basic'
  'Standard'
])
param bastionSku string = 'Basic'

@allowed([
  'VpnGw1AZ'
  'VpnGw2AZ'
  'VpnGw3AZ'
])
param vpnGatewaySku string = 'VpnGw1AZ'

// Subnets
var firewallSubnet = enableFirewall ? [
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: hubSubnetCidrs.firewall
  }
] : []

var gatewaySubnet = enableVpnGateway ? [
  {
    name: 'GatewaySubnet'
    addressPrefix: hubSubnetCidrs.gateway
  }
] : []

var bastionSubnet = enableBastion ? [
  {
    name: 'AzureBastionSubnet'
    addressPrefix: hubSubnetCidrs.bastion
  }
] : []

var baseSubnets = [
  {
    name: 'AzureDnsSubnet'
    addressPrefix: hubSubnetCidrs.dns
  }
  {
    name: 'ManagementSubnet'
    addressPrefix: hubSubnetCidrs.management
  }
]

var hubSubnets = concat(firewallSubnet, gatewaySubnet, bastionSubnet, baseSubnets)

var hubSubnetObjects = [for subnet in hubSubnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
  }
}]

// VNet
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: hubVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressSpace
      ]
    }
    subnets: hubSubnetObjects
  }
}

// Firewall
resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (enableFirewall) {
  name: 'pip-${prefix}-azfw-${location}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-11-01' = if (enableFirewall) {
  name: 'azfw-${prefix}-${location}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: firewallTier
    }
    ipConfigurations: [
      {
        name: 'fw-ipconfig'
        properties: {
          subnet: {
            id: '${hubVnet.id}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
  }
}

// Bastion
resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (enableBastion) {
  name: 'pip-${prefix}-bas-${location}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-11-01' = if (enableBastion) {
  name: 'bas-${prefix}-${location}'
  location: location
  tags: tags
  sku: {
    name: bastionSku
  }
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-ipconfig'
        properties: {
          subnet: {
            id: '${hubVnet.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}

// VPN gateway public IP
resource vpnGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = if (enableVpnGateway) {
  name: 'pip-${prefix}-vpngw-${location}'
  location: location

  zones: [
    '1'
    '2'
    '3'
  ]

  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// VPN Gateway
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-11-01' = if (enableVpnGateway) {
  name: 'vpngw-${prefix}-${location}'
  location: location
  tags: tags
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    activeActive: false
    enableBgp: false
    sku: {
      name: vpnGatewaySku
      tier: vpnGatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${hubVnet.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: vpnGatewayPublicIp.id
          }
        }
      }
    ]
  }
}

// Outputs
output hubVnetId string = hubVnet.id
output hubVnetName string = hubVnet.name