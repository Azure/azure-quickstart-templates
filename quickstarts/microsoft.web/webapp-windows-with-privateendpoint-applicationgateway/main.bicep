@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the WebApp')
param siteName string = 'AppService0001'

@description('Address prefix for the Virtual Network')
var addressPrefix  = '10.0.0.0/16'

@description('Subnet prefix of the App Gateway')
var AppGatewaySubnetPrefix  = '10.0.0.0/28'

@description('Subnet prefix of the Private Endpoint of the Web App ')
var PrivateEndPointSubnetPrefix  = '10.0.1.0/28'

@description('Name of your Private Endpoint')
var privateEndpoint_name  = '${siteName}-privateEndpoint'


@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
  'P1v3'
  'P2v3'
  'P3v3'
])
param ASPSKU string = 'B1'

@description('Name of the Subnet for PrivateEndpoint')
var PESubnetName  = '${siteName}-PeSubnet'

@description('Link name between your Private Endpoint and your Web App')
var privateLinkConnection_name = '${siteName}-privatelinkconnection'

@description('Name must be privatelink.azurewebsites.net')
var privateDNSZone_name = 'privatelink.azurewebsites.net'

@description('Virtual Network Resouce Name')
var virtualNetworkNameResource = '${siteName}-virtualNetwork'

@description('App Gateway Resource name')
var applicationGatewayNameResource = '${siteName}-agw'

@description('Name of the Subnet for ApplicationGateway')
var subnetName = '${applicationGatewayNameResource}-appGatewaySubnet'

@description('Public Ip Resource Name')
var publicIPAddressNameResource = '${siteName}-pip'

@description('App Service Plan Resource name')
var hostingPlanNameResource = '${siteName}-serviceplan'

var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkNameResource, subnetName)
var publicIPRef = publicIPAddressName.id

resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIPAddressNameResource
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource virtualNetworkName 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkNameResource
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: AppGatewaySubnetPrefix
        }
      }, {
        name: PESubnetName
        properties: {
          addressPrefix: PrivateEndPointSubnetPrefix
        }
      }
    ]
  }
}

resource ApplicationGateway 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: applicationGatewayNameResource
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: publicIPRef
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: AppService.properties.defaultHostName
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          hostName: '${siteName}.azurewebsites.net'
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          probeEnabled: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes/', applicationGatewayNameResource, 'Probe1')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations/', applicationGatewayNameResource, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts/', applicationGatewayNameResource, 'appGatewayFrontendPort')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          priority: 100
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners/', applicationGatewayNameResource, 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools/', applicationGatewayNameResource, 'appGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection/', applicationGatewayNameResource, 'appGatewayBackendHttpSettings')
          }
        }
      }
    ]
    probes: [
      {
        name: 'Probe1'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 10
          unhealthyThreshold: 3
          minServers: 0
          pickHostNameFromBackendHttpSettings: true
        }
      }
    ]
  }
  dependsOn: [
    virtualNetworkName

  ]
}

resource hostingPlanName 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanNameResource
  location: location
  tags: {
    displayName: 'HostingPlan'
  }
  sku: {
    name: ASPSKU
  }
  kind: 'app'
}

resource AppService 'Microsoft.Web/sites@2022-03-01' = {
  name: siteName
  location: location
  properties: {

    serverFarmId: hostingPlanName.id
  }
}

resource PrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: privateEndpoint_name
  location: location
  properties: {
    subnet: {
      id: virtualNetworkName.properties.subnets[1].id
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnection_name
        properties: {
          privateLinkServiceId: AppService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDNSZone_name
  location: 'global'
  dependsOn: [
    virtualNetworkName
  ]
}

resource privateDNSZonePrivateDNSZonelink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  name: '${privateDNSZone_name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkName.id
    }
  }
}

resource privateEndpointDnsGroupname 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  parent: PrivateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDNSZone.id
        }
      }
    ]
  }
}
