@description('Azure Region for the first secure Virtual WAN Hub.')
param virtualHubRegionOne string = 'northeurope'

@description('Azure Region for the second secure Virtual WAN Hub.')
param virtualHubRegionTwo string = 'northeurope'

@description('Address prefix for the first secure Virtual WAN Hub. The minimum address prefix is /24')
param virtualHubRegionOneAddressPrefix string = '10.0.0.0/24'

@description('Address prefix for the second secure Virtual WAN Hub. The minimum address prefix is /24')
param virtualHubRegionTwoAddressPrefix string = '10.1.0.0/24'

@description('Enable User VPN Gateways for secure Virtual WAN Hubs')
param virtualHubEnableUserVPNGateways bool = false

@description('User VPN Gateways scale unit')
@minValue(1)
@maxValue(20)
param virtualHubUserVPNGatewaysScaleUnit int = 1

@description('The address prefix from which IP addresses will be automatically assigned to VPN clients for the first secure Virtual WAN Hub. The minimum address prefix is /23, the maximum is /18.')
param virtualHubRegionOneUserVPNClientAddressPrefix string = '10.0.254.0/23'

@description('The address prefix from which IP addresses will be automatically assigned to VPN clients for the second secure Virtual WAN Hub. The minimum address prefix is /23, the maximum is /18.')
param virtualHubRegionTwoUserVPNClientAddressPrefix string = '10.1.254.0/23'

@description('Enable VPN Gateways for secure Virtual WAN Hubs')
param virtualHubEnableVPNGateways bool = false

@description('VPN Gateways scale unit')
@minValue(1)
@maxValue(20)
param virtualHubVPNGatewaysScaleUnit int = 1

@description('Enable ExpressRoute Gateways for secure virtual WAN hubs.')
param virtualHubEnableExpressRouteGateways bool = false

@description('ExpressRoute Gateways scale unit')
@minValue(1)
@maxValue(10)
param virtualHubExpressRouteGatewaysScaleUnit int = 1

@description('The address prefix to be used by the first virtual network')
param virtualNetworkOneAddressPrefix string = '10.0.2.0/24'

@description('The address prefix to be used by the second virtual network')
param virtualNetworkTwoAddressPrefix string = '10.0.3.0/24'

@description('The address prefix to be used by the third virtual network')
param virtualNetworkThreeAddressPrefix string = '10.1.2.0/24'

@description('The address prefix to be used by the fourth virtual network')
param virtualNetworkFourAddressPrefix string = '10.1.3.0/24'

var virtualHubConfigs = [
  {
    location: virtualHubRegionOne
    addressPrefix: virtualHubRegionOneAddressPrefix
    enableVPNGateway: virtualHubEnableVPNGateways
    vpnGatewayScaleUnit: virtualHubVPNGatewaysScaleUnit
    enableUserVPNGateway: virtualHubEnableUserVPNGateways
    userVPNGatewayScaleUnit: virtualHubUserVPNGatewaysScaleUnit
    userVPNGatewayClientAddressPrefix: virtualHubRegionOneUserVPNClientAddressPrefix
    enableExpressRouteGateway: virtualHubEnableExpressRouteGateways
    expressRouteGatewayScaleUnit: virtualHubExpressRouteGatewaysScaleUnit
  }
  {
    location: virtualHubRegionTwo
    addressPrefix: virtualHubRegionTwoAddressPrefix
    enableVPNGateway: virtualHubEnableVPNGateways
    vpnGatewayScaleUnit: virtualHubVPNGatewaysScaleUnit
    enableUserVPNGateway: virtualHubEnableUserVPNGateways
    userVPNGatewayScaleUnit: virtualHubUserVPNGatewaysScaleUnit
    userVPNGatewayClientAddressPrefix: virtualHubRegionTwoUserVPNClientAddressPrefix
    enableExpressRouteGateway: virtualHubEnableExpressRouteGateways
    expressRouteGatewayScaleUnit: virtualHubExpressRouteGatewaysScaleUnit
  }
]

var aadIssuer = 'https://sts.windows.net/${tenant().tenantId}/'
var aadTenant = '${environment().authentication.loginEndpoint}${tenant().tenantId}/'

var virtualNetworkConfigs = [
  {
    location: virtualHubRegionOne
    addressPrefix: virtualNetworkOneAddressPrefix
  }
  {
    location: virtualHubRegionOne
    addressPrefix: virtualNetworkTwoAddressPrefix
  }
  {
    location: virtualHubRegionTwo
    addressPrefix: virtualNetworkThreeAddressPrefix
  }
  {
    location: virtualHubRegionTwo
    addressPrefix: virtualNetworkFourAddressPrefix
  }
]

resource virtualWan 'Microsoft.Network/virtualWans@2021-05-01' = {
  name: 'vwan-${uniqueString(resourceGroup().id)}'
  location: virtualHubRegionOne
  properties: {
    type: 'Standard'
  }
}

resource virtualHubs 'Microsoft.Network/virtualHubs@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: {
  name: 'vhub-${uniqueString(resourceGroup().id)}-region${i+1}'
  location: virtualHub.location
  properties: {
    virtualWan: {
      id: virtualWan.id
    }
    addressPrefix: virtualHub.addressPrefix
  }
}]

resource UserVPNConfiguration 'Microsoft.Network/vpnServerConfigurations@2021-05-01' = if (virtualHubEnableVPNGateways) {
  name: '${virtualWan.name}-user-vpn-config' 
  location: virtualHubRegionOne
  properties: {
    aadAuthenticationParameters: {
      aadAudience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
      aadIssuer: aadIssuer
      aadTenant: aadTenant
    }
    vpnProtocols: [
      'OpenVPN'
    ]
    vpnAuthenticationTypes: [
      'AAD'
    ]
  }
}

resource virtualHubUserVPNGateways 'Microsoft.Network/p2svpnGateways@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: if (virtualHub.enableUserVPNGateway) {
  name: 'uvpng-${uniqueString(resourceGroup().id)}-region${i+1}'
  location: virtualHub.location
  properties: {
    p2SConnectionConfigurations: [
      {
        name: '${virtualHubs[i].name}-user-vpn-config' 
        properties: {
          vpnClientAddressPool: {
            addressPrefixes: [
              virtualHub.userVPNGatewayClientAddressPrefix
            ]
          }
        }
      }
    ]
    virtualHub: {
      id: virtualHubs[i].id
    }
    vpnGatewayScaleUnit: virtualHub.userVPNGatewayScaleUnit
    vpnServerConfiguration: {
      id: UserVPNConfiguration.id
    }
  }
}]

resource virtualHubVPNGateways 'Microsoft.Network/vpnGateways@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: if (virtualHub.enableVPNGateway) {
  name: 'vpng-${uniqueString(resourceGroup().id)}-region${i+1}'
  location: virtualHub.location
  properties: {
    virtualHub: {
      id: virtualHubs[i].id
    }
    vpnGatewayScaleUnit: virtualHub.vpnGatewayScaleUnit
  } 
}]

resource virtualHubExpressRouteGateways 'Microsoft.Network/expressRouteGateways@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: if (virtualHub.enableExpressRouteGateway) {
  name: 'exrgw-${uniqueString(resourceGroup().id)}-region${i+1}'
  location: virtualHub.location
  properties: {
    autoScaleConfiguration: {
      bounds: {
        min: virtualHub.ExpressRouteGatewayScaleUnit
      }
    }
    virtualHub: {
      id: virtualHubs[i].id
    }
  }
}]

resource defaultAzureFirewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: 'afwp-${uniqueString(resourceGroup().id)}'
  location: virtualHubRegionOne
  properties: {
    sku: {
      tier: 'Standard'
    }
  }
}

resource azureFirewallPolicies 'Microsoft.Network/firewallPolicies@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: {
  name: 'afwp-${uniqueString(resourceGroup().id)}-region${i+1}'
  location: virtualHub.location
  properties: {
    basePolicy: {
      id: defaultAzureFirewallPolicy.id
    }
    sku: {
      tier: 'Standard'
    }
  }
}]

resource azureFirewalls 'Microsoft.Network/azureFirewalls@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: {
  name: 'afw-${uniqueString(resourceGroup().id)}-region${i+1}'
  location: virtualHub.location
  properties: {
    firewallPolicy: {
      id: azureFirewallPolicies[i].id
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    virtualHub: {
      id: virtualHubs[i].id
    }
  }
}]

/* Routing Intent Policies 
resource defaultRoutingIntents 'Microsoft.Network/virtualHubs/routingIntent@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: {
  parent: virtualHubs[i]
  name: 'Default'
  properties: {
    routingPolicies: [
      {
        destinations: [
          '0.0.0.0/0'
        ]
        name: '_Policy_Public'
        nextHop: azureFirewalls[i].id
      }
      {
        destinations: [
          '10.0.0.0/8'
          '172.16.0.0/12'
          '192.168.0.0/16'
        ]
        name: '_Policy_Private'
        nextHop: azureFirewalls[i].id
      }
    ]
  }
}]

resource noneRoutingIntents 'Microsoft.Network/virtualHubs/routingIntent@2021-05-01' = [for (virtualHub, i) in virtualHubConfigs: {
  parent: virtualHubs[i]
  name: 'None'
}]
*/

resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2021-05-01' = [for (virtualNetwork, i) in virtualNetworkConfigs: {
  name: 'nsg-${uniqueString(resourceGroup().id)}-00${i+1}'
  location: virtualNetwork.location
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2021-05-01' = [for (virtualNetwork, i) in virtualNetworkConfigs: {
  name: 'vnet-${uniqueString(resourceGroup().id)}-00${i+1}'
  location: virtualNetwork.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork.addressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-${uniqueString(resourceGroup().id)}-00${i+1}'
        properties: {
          addressPrefix: virtualNetwork.addressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroups[i].id
          }
        }
      }
    ]
  }
}]
