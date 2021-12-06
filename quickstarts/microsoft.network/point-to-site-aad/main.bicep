@description('Name for the virtual network')
param virtualNetworkName string = 'VNet1'

@description('Location for the resources')
param location string = resourceGroup().location

@description('Name for the frontend subnet')
param frontendSubName string = 'FrontEnd'

@description('CIDR block representing the address space of the VNet')
param virtualNetworkPrefix string = '10.1.0.0/16'

@description('CIDR block for the front end subnet, subset of VNet address space')
param frontendSubPrefix string = '10.1.0.0/24'

@description('CIDR block for the gateway subnet, subset of VNet address space')
param gatewaySubPrefix string = '10.1.255.0/27'

@description('Name for the new gateway')
param gatewayName string = 'VNet1GW'

@description('Name for public IP resource used for the new azure gateway')
param gatewayPublicIPName string = 'VNet1GWIP'

@description('The SKU of the Gateway. This must be either Standard or HighPerformance to work with OpenVPN')
@allowed([
  'Standard'
  'HighPerformance'
])
param gatewaySku string = 'Standard'

@description('Route based (Dynamic Gateway) or Policy based (Static Gateway)')
@allowed([
  'RouteBased'
  'PolicyBased'
])
param vpnType string = 'RouteBased'

@description('The IP address range from which VPN clients will receive an IP address when connected. Range specified must not overlap with on-premise network')
param vpnClientAddressPool string = '172.16.0.0/24'

var audienceMap = {
  AzureCloud: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
  AzureUSGovernment: '51bb15d4-3a4f-4ebf-9dca-40096fe32426'
  AzureGermanCloud: '538ee9e6-310a-468d-afef-ea97365856a9'
  AzureChinaCloud: '49f817b6-84ae-4cc0-928c-73f27289b3aa'
}

var tenantId = subscription().tenantId
var cloud = environment().name
var audience = audienceMap[cloud]
var tenant = uri(environment().authentication.loginEndpoint, tenantId)
var issuer = 'https://sts.windows.net/${tenantId}/'
var gatewaySubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'GatewaySubnet')
var publicIPAddressRef =  resourceId('Microsoft.Network/publicIPAddresses', gatewayPublicIPName)

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01'= {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets: [
      {
        name: frontendSubName
        properties:{
          addressPrefix: frontendSubPrefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties:{
          addressPrefix: gatewaySubPrefix
        }
      }
    ]
  }

}

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: gatewayName
  location: location
  dependsOn: [
    virtualNetwork
    publicIp
  ]
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetRef
          }
          publicIPAddress: {
            id: publicIPAddressRef
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: 'Vpn'
    vpnType: vpnType
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          vpnClientAddressPool
        ]
      }
      vpnClientProtocols: [
        'OpenVPN'
      ]
      vpnAuthenticationTypes: [
        'AAD'
      ]
      aadTenant: tenant
      aadAudience: audience
      aadIssuer: issuer
    }
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: gatewayPublicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
