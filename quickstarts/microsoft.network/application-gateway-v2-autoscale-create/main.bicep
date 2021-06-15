@description('Virtual Network name')
param virtualNetworkName string = 'Application-Vnet'

@description('Virtual Network address range')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Name of the subnet')
param subnetName string = 'ApplicationGatewaySubnet'

@description('Subnet address range')
param subnetPrefix string = '10.0.0.0/24'

@description('Application Gateway name')
param applicationGatewayName string = 'applicationGatewayV2'

@description('Minimum instance count for Application Gateway')
param minCapacity int = 2

@description('Maximum instance count for Application Gateway')
param maxCapacity int = 10

@description('Application Gateway Frontend port')
param frontendPort int = 80

@description('Application gateway Backend port')
param backendPort int = 80

@description('Back end pool ip addresses')
param backendIPAddresses array = [
  {
    IpAddress: '10.0.0.4'
  }
  {
    IpAddress: '10.0.0.5'
  }
]

@description('Cookie based affinity')
@allowed([
  'Enabled'
  'Disabled'
])
param cookieBasedAffinity string = 'Disabled'

@description('Location for all resources.')
param location string = resourceGroup().location

var appGwPublicIpName = '${applicationGatewayName}-pip'
var appGwSize = 'Standard_v2'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: appGwPublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-06-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: appGwSize
      tier: 'Standard_v2'
    }
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          port: frontendPort
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties: {
          backendAddresses: backendIPAddresses
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: backendPort
          protocol: 'Http'
          cookieBasedAffinity: cookieBasedAffinity
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'appGatewayFrontendPort')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'appGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'appGatewayBackendHttpSettings')
          }
        }
      }
    ]
  }
}
