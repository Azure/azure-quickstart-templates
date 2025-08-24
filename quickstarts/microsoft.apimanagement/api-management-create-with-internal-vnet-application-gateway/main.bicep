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

@description('Email address associated with publisher')
param apim_publisher_email string = 'api@contoso.com'

var appInsightName = '${base_name}-ai'
var vnetName = '${base_name}-vnet'
var apimName = '${base_name}-apim'
var publicIPName = '${base_name}-pip'
var gatewayName = '${base_name}-agw'
var vnet_dns_link_name = '${base_name}-vnet-dns-link'

resource apim 'Microsoft.ApiManagement/service@2022-08-01' = {
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
      subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'apimSubnet')
    }
  }
  dependsOn: [
    vNet
  ]
}

resource gateway 'Microsoft.ApiManagement/service/gateways@2022-08-01' = {
  parent: apim
  name: 'my-gateway'
  properties: {
    locationData: {
      name: 'My internal location'
    }
    description: 'Self hosted gateway bringing API Management to the edge'
  }
}

resource logger 'Microsoft.ApiManagement/service/loggers@2022-08-01' = {
  parent: apim
  name: 'AppInsightsLogger'
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsight.id
    credentials: {
      instrumentationKey: appInsight.properties.InstrumentationKey
    }
  }
}

resource apimAppInsights 'Microsoft.ApiManagement/service/diagnostics@2022-08-01' = {
  parent: apim
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'information'
    logClientIp: true
    loggerId: logger.id
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

resource apimlogToAnalytics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apim
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

resource appGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: gatewayName
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
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'appGatewaySubnet')
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
            id: publicIP.id
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
            id: resourceId('Microsoft.Network/applicationGateways/probes', gatewayName, 'apim-gateway-probe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'apim-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontEndIPConfigurations', gatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontEndPorts', gatewayName, 'port_80')
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
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', gatewayName, 'apim-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', gatewayName, 'gatewayBackEnd')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', gatewayName, 'apim-gateway-https-setting')
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
    appInsight
    vNet
    dnsZone
  ]
}

resource appGatewaylogToAnalytics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
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

resource appInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: log_analytics_workspace_id
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPName
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

resource vNet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
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

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'azure-api.net'
  location: 'global'
  properties: {}
  dependsOn: [
    apim
    vNet
  ]
}

resource dnsZoneA 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (true) {
  parent: dnsZone
  name: apimName
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apim.properties.privateIPAddresses[0]
      }
    ]
  }
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: dnsZone
  name: vnet_dns_link_name
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vNet.id
    }
  }
}

output publicEndpointFqdn string = publicIP.properties.dnsSettings.fqdn
