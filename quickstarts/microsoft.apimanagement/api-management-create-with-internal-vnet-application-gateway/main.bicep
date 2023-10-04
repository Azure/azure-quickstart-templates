@description('This will be used to derive names for all of your resources')
param base_name string

@description('The resource ID for an existing Log Analytics workspace')
param log_analytics_workspace_id string

@description('Location in which resources will be created')
param location string = resourceGroup().location

@description('The edition of Azure API Management to use. This must be an edition that supports VNET Integration. This selection can have a significant impact on consumption cost and \'Developer\' is recommended for non-production use.')
@allowed([
  'Developer'
  'Premium'
])
param apim_sku string = 'Developer'

@description('The number of Azure API Management capacity units to provision. For Developer edition, this must equal 1.')
param apim_capacity int = 1

@description('The number of Azure Application Gateway capacity units to provision. This setting has a direct impact on consumption cost and is recommended to be left at the default value of 1')
param app_gateway_capacity int = 1

@description('The address space (in CIDR notation) to use for the VNET to be deployed in this solution. If integrating with other networked components, there should be no overlap in address space.')
param vnet_address_prefix string = '10.0.0.0/16'

@description('The address space (in CIDR notation) to use for the subnet to be used by Azure Application Gateway. Must be contained in the VNET address space.')
param app_gateway_subnet_prefix string = '10.0.0.0/24'

@description('The address space (in CIDR notation) to use for the subnet to be used by Azure API Management. Must be contained in the VNET address space.')
param apim_subnet_prefix string = '10.0.1.0/24'

@description('Descriptive name for publisher to be used in the portal')
param apim_publisher_name string = 'Contoso'

@description('Email adddress associated with publisher')
param apim_publisher_email string = 'api@contoso.com'

var appInsightsName = '${base_name}-ai'
var vnetName = '${base_name}-vnet'
var apimName = '${base_name}-apim'
var publicIpName = '${base_name}-pip'
var appGatewayName = '${base_name}-agw'
var vnetDnsLinkname = '${base_name}-vnet-dns-link'

resource apimService 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apimName
  location: location
  sku: {
    name: apim_sku
    capacity: apim_capacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherName: apim_publisher_name
    publisherEmail: apim_publisher_email
    virtualNetworkType: 'Internal'
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnet.id
    }
  }
}

resource apimGateway 'Microsoft.ApiManagement/service/gateways@2022-08-01' = {
  parent: apimService
  name: 'my-gateway'
  properties: {
    locationData: {
      name: 'My internal location'
    }
    description: 'Self hosted gateway bringing API Management to the edge'
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2022-08-01' = {
  parent: apimService
  name: 'AppInsightsLogger'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightComponent.id
    credentials: {
      instrumentationKey: appInsightComponent.properties.InstrumentationKey
    }
  }
}

resource apimDiagnostic 'Microsoft.ApiManagement/service/diagnostics@2022-08-01' = {
  parent: apimService
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'information'
    logClientIp: true
    loggerId: apimLogger.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        body: {
          bytes: 0
        }
      }
      response: {
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        body: {
          bytes: 0
        }
      }
      response: {
        body: {
          bytes: 0
        }
      }
    }
  }
}

resource diagnosticSettingLogService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apimService
  name: 'logToAnalytics'
  properties: {
    workspaceId: log_analytics_workspace_id
    logs: [
      {
        category: 'GatewayLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: app_gateway_capacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appGatewaySubnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'gatewayBackEnd'
        properties: {
          backendAddresses: [
            {
              fqdn: '${apimName}.azure-api.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'apim-gateway-https-setting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: '${apimName}.azure-api.net'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'apim-gateway-probe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'apim-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontEndIPConfigurations', appGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontEndPorts', appGatewayName, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'apim-routing-rule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'apim-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'gatewayBackEnd')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'apim-gateway-https-setting')
          }
        }
      }
    ]
    probes: [
      {
        name: 'apim-gateway-probe'
        properties: {
          protocol: 'Https'
          host: '${apimName}.azure-api.net'
          port: 443
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 120
          unhealthyThreshold: 8
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
  }
  dependsOn: [
    appInsightComponent
    privateDnsZone
  ]
}

resource diagnosticSettingGateway 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appGateway
  name: 'logToAnalytics'
  properties: {
    workspaceId: log_analytics_workspace_id
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource appInsightComponent 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: log_analytics_workspace_id
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: base_name
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_address_prefix
      ]
    }
    subnets: [
      {
        type: 'subnets'
        name: 'appGatewaySubnet'
        properties: {
          addressPrefix: app_gateway_subnet_prefix
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        type: 'subnets'
        name: 'apimSubnet'
        properties: {
          addressPrefix: apim_subnet_prefix
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: 'apimSubnet'
}

resource appGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: 'appGatewaySubnet'
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'azure-api.net'
  location: 'global'
  properties: {}
  dependsOn: [
    apimService
    vnet
  ]
}

resource privateDnsZoneA 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (true) {
  parent: privateDnsZone
  name: apimName
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apimService.properties.privateIPAddresses[0]
      }
    ]
  }
}

resource vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: vnetDnsLinkname
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnet.id
    }
  }
}

output publicEndpointFqdn string = publicIPAddress.properties.dnsSettings.fqdn
