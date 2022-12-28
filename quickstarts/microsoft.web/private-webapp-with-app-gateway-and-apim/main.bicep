@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

// ---- Azure API Management parameters ----
@description('A unique name for the API Management service. The service name refers to both the service and the corresponding Azure resource. The service name is used to generate a default domain name: <name>.azure-api.net.')
param apiManagementPublisherName string

@description('The email address to which all the notifications from API Management will be sent.')
param apiManagementPublisherEmailAddress string

@description('The API Management SKU.')
@allowed([
  'Developer'
  'Premium'
])
param apiManagementSku string = 'Developer'

@description('A custom domain name to be used for the API Management service.')
param apiManagementCustomDnsName string

@description('A custom domain name for the API Management service developer portal (e.g., portal.consoto.com). ')
param apiManagementPortalCustomHostname string

@description('A custom domain name for the API Management service gateway/proxy endpoint (e.g., api.consoto.com).')
param apiManagementProxyCustomHostname string

@description('A custom domain name for the API Management service management portal (e.g., management.consoto.com).')
param apiManagementManagementCustomHostname string

@description('Password for corresponding to the certificate for the API Management custom developer portal domain name.')
@secure()
param apiManagementPortalCertificatePassword string

@description('Used by Application Gateway, the Base64 encoded PFX certificate corresponding to the API Management custom developer portal domain name.')
@secure()
param apiManagementPortalCustomHostnameBase64EncodedCertificate string

@description('Password for corresponding to the certificate for the API Management custom proxy domain name.')
@secure()
param apiManagementProxyCertificatePassword string

@description('Used by Application Gateway, the Base64 encoded PFX certificate corresponding to the API Management custom proxy domain name.')
@secure()
param apiManagementProxyCustomHostnameBase64EncodedCertificate string

@description('Password for corresponding to the certificate for the API Management custom management domain name.')
@secure()
param apiManagementManagementCertificatePassword string

@description('Used by Application Gateway, the Base64 encoded PFX certificate corresponding to the API Management custom management domain name.')
@secure()
param apiManagementManagementCustomHostnameBase64EncodedCertificate string

// ---- Application Gateway parameters ----
@description('Used by Application Gateway, the Base64 encoded CER/CRT certificate corresponding to the root certificate for Application Gateway.')
@secure()
param applicationGatewayTrustedRootBase64EncodedCertificate string

@description('Flag to indicate if certificates used by Application Gateway were signed by a public Certificate Authority.')
param useWellKnownCertificateAuthority bool = true

// ---- Virtual Network parameters ----
@description('The virtual network IP space to use for the new virutal network.')
param vnetAddressPrefix string = '10.0.0.0/20'

@description('The IP space to use for the subnet for Azure App Service regional virtual network integration.')
param subnetAppServiceIntAddressPrefix string = '10.0.3.0/26'

@description('The IP space to use for the subnet for private endpoints.')
param subnetPrivateEndpointAddressPrefix string = '10.0.4.0/26'

@description('Address prefix for the api subnet.')
param subnetApiManagementAddressPrefix string = '10.0.5.0/24'

@description('Address prefix for the gateway subnet.')
param subnetApplicationGatewayAddressPrefix string = '10.0.6.0/24'

// ---- Azure Web App parameters
@description('SKU name, must be minimum P1v2')
@allowed([
  'P1v2'
  'P1v3'
  'P2v2'
  'P2v3'
  'P3v2'
  'P3v3'
])
param webAppSkuName string = 'P1v2'

// ---- Variables ----
var baseName = uniqueString(resourceGroup().id)
var keyVaultName = 'kv-${baseName}'
var applicationGatewayName = 'agw-${baseName}'
var apiManagementServiceName = 'apim-${baseName}'
var appGatewayPublicIpAddressName = 'pip-${baseName}-agw'

var vnetName = 'vnet-${baseName}'
var subnetApiManagementName = 'snet-${baseName}-apim'
var subnetAppGatewayName = 'snet-${baseName}-agw'
var subnetPrivateEndpointName = 'snet-${baseName}-pe'
var subnetAppServiceIntName = 'snet-${baseName}-ase'

var nsgAppGatewayName = 'nsg-${baseName}-agw'
var nsgApiManagementName = 'nsg-${baseName}-apim'

var apimSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetApiManagementName)
var appGatewaySubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetAppGatewayName)
var appServiceIntegrationSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetAppServiceIntName)
var privateEndpointSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetPrivateEndpointName)

var webAppName = 'web-${baseName}'

var applicationGatewayTrustedRootCertificates = [
  {
    name: 'trustedrootcert'
    properties: {
      data: applicationGatewayTrustedRootBase64EncodedCertificate
    }
  }
]

var applicationGatewayTrustedRootCertificateReferences = [
  {
    id: resourceId('Microsoft.Network/applicationGateways/trustedRootCertificates', applicationGatewayName, 'trustedrootcert')
  }
]

// ---- Create Virtual Network with subnets ----
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetAppServiceIntName
        properties: {
          addressPrefix: subnetAppServiceIntAddressPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: subnetPrivateEndpointName
        properties: {
          addressPrefix: subnetPrivateEndpointAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: subnetApiManagementName
        properties: {
          addressPrefix: subnetApiManagementAddressPrefix
          networkSecurityGroup: {
            id: nsgApiManagemnt.id
          }
        }
      }
      {
        name: subnetAppGatewayName
        properties: {
          addressPrefix: subnetApplicationGatewayAddressPrefix
          networkSecurityGroup: {
            id: nsgAppGateway.id
          }
        }
      }
    ]
  }
}

// ---- Create Network Security Groups (NSGs) ----
resource nsgAppGateway 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgAppGatewayName
  location: location
  properties: {
    securityRules: [
      {
        name: 'agw-in'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          description: 'App Gateway inbound'
          priority: 100
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '65200-65535'
        }
      }
      {
        name: 'https-in'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
          description: 'Allow HTTPS Inbound'
        }
      }
    ]
  }
}

resource nsgApiManagemnt 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgApiManagementName
  location: location
  properties: {
    securityRules: [
      {
        name: 'apim-in'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          description: 'API Management inbound'
          priority: 100
          sourceAddressPrefix: 'ApiManagement'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3443'
        }
      }
    ]
  }
}

// ---- Public IP Address ----
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: appGatewayPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

// ---- Private DNS Zone ----
resource apiManagementPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: apiManagementCustomDnsName
  location: 'global'

  resource apiRecord 'A' = {
    name: 'api'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apiManagementInstance.properties.privateIPAddresses[0]
        }
      ]
    }
  }

  resource managementRecord 'A' = {
    name: 'management'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apiManagementInstance.properties.privateIPAddresses[0]
        }
      ]
    }
  }

  resource portalRecord 'A' = {
    name: 'portal'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apiManagementInstance.properties.privateIPAddresses[0]
        }
      ]
    }
  }

  resource link 'virtualNetworkLinks' = {
    name: 'privateDnsZoneLink'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

resource webAppPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'

  resource link 'virtualNetworkLinks' = {
    name: 'webAppPrivateDnsZoneLink'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

// ---- Private Endpoint ----
resource webAppPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-${baseName}-sites'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${baseName}-sites'
        properties: {
          privateLinkServiceId: webApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }

  resource webAppPrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'webAppPrivateDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: webAppPrivateDnsZone.id
          }
        }
      ]
    }
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-${baseName}-kv'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
      name: subnetPrivateEndpointName
    }
    privateLinkServiceConnections: [
      {
        id: keyVault.id
        name: 'plsc-${baseName}-kv'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }

  resource keyVaultPrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'keyVaultPrivateDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: keyVaultPrivateDnsZone.id
          }
        }
      ]
    }
  }
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'Global'

  resource keyVaultPrivateDnsZoneLink 'virtualNetworkLinks' = {
    name: 'keyVaultPrivateDnsZoneLink'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

// ---- Application Insights ----
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${baseName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'log-${baseName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// ---- Azure Web App ----
resource webAppPlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: 'plan-${baseName}'
  location: location
  kind: 'app'
  sku: {
    name: webAppSkuName
    capacity: 1
  }
  properties: {}
}

resource webApp 'Microsoft.Web/sites@2020-12-01' = {
  name: webAppName
  location: location
  kind: 'app'
  dependsOn: [
    virtualNetwork
  ]
  properties: {
    httpsOnly: true
    serverFarmId: webAppPlan.id

    // Specify a virtual network subnet resource ID to enable regional virtual network integration.
    virtualNetworkSubnetId: appServiceIntegrationSubnetId
    siteConfig: {
      vnetRouteAllEnabled: true
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource config 'config' = {
    name: 'web'
    properties: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      remoteDebuggingEnabled: false
    }
  }
}

resource webAppSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${webAppName}/appsettings'
  dependsOn: [
    webApp
  ]
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: '@Microsoft.KeyVault(SecretUri=${keyVault::appInsightsInstrumentationKeyKeyVaultSecret.properties.secretUri})'
  }
}

// ---- Azure API Management and related API operations ----
resource apiManagementInstance 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apiManagementServiceName
  dependsOn: [
    virtualNetwork
  ]
  location: location
  sku: {
    capacity: 1
    name: apiManagementSku
  }
  properties: {
    publisherEmail: apiManagementPublisherEmailAddress
    publisherName: apiManagementPublisherName
    virtualNetworkType: 'Internal'
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
    hostnameConfigurations: [
      {
        type: 'DeveloperPortal'
        hostName: apiManagementPortalCustomHostname
        encodedCertificate: apiManagementPortalCustomHostnameBase64EncodedCertificate
        certificatePassword: apiManagementPortalCertificatePassword
        negotiateClientCertificate: false
      }
      {
        type: 'Proxy'
        hostName: apiManagementProxyCustomHostname
        encodedCertificate: apiManagementProxyCustomHostnameBase64EncodedCertificate
        certificatePassword: apiManagementProxyCertificatePassword
        negotiateClientCertificate: false
      }
      {
        type: 'Management'
        hostName: apiManagementManagementCustomHostname
        encodedCertificate: apiManagementManagementCustomHostnameBase64EncodedCertificate
        certificatePassword: apiManagementManagementCertificatePassword
        negotiateClientCertificate: false
      }
    ]
  }

  resource appInsightsLogger 'loggers' = {
    name: 'appInsightsLogger'
    properties: {
      loggerType: 'applicationInsights'
      credentials: {
        instrumentationKey: applicationInsights.properties.InstrumentationKey
      }
    }
  }

  resource appInsightsDiagnostics 'diagnostics' = {
    name: 'applicationinsights'
    properties: {
      loggerId: appInsightsLogger.id
      logClientIp: true
      alwaysLog: 'allErrors'
      verbosity: 'information'
      sampling: {
        percentage: 100
        samplingType: 'fixed'
      }
      httpCorrelationProtocol: 'Legacy'
    }
  }
}

resource apiManagementDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apiManagementInstance
  name: 'apiManagementDiagnosticSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

// ---- Azure Application Gateway ----
resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: location
  dependsOn: [
    virtualNetwork
    apiManagementPrivateDnsZone
    apiManagementInstance
  ]
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'gatewayIP01'
        properties: {
          subnet: {
            id: appGatewaySubnetId
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'gatewaycert'
        properties: {
          data: apiManagementProxyCustomHostnameBase64EncodedCertificate
          password: apiManagementProxyCertificatePassword
        }
      }
      {
        name: 'portalcert'
        properties: {
          data: apiManagementPortalCustomHostnameBase64EncodedCertificate
          password: apiManagementPortalCertificatePassword
        }
      }
      {
        name: 'managementcert'
        properties: {
          data: apiManagementManagementCustomHostnameBase64EncodedCertificate
          password: apiManagementManagementCertificatePassword
        }
      }
    ]
    trustedRootCertificates: useWellKnownCertificateAuthority ? null : applicationGatewayTrustedRootCertificates
    frontendIPConfigurations: [
      {
        name: 'frontend1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: applicationGatewayPublicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port01'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'gatewaybackend'
        properties: {
          backendAddresses: [
            {
              fqdn: apiManagementProxyCustomHostname
            }
          ]
        }
      }
      {
        name: 'portalbackend'
        properties: {
          backendAddresses: [
            {
              fqdn: apiManagementPortalCustomHostname
            }
          ]
        }
      }
      {
        name: 'managementbackend'
        properties: {
          backendAddresses: [
            {
              fqdn: apiManagementManagementCustomHostname
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'apimPoolGatewaySetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 180
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'apimgatewayprobe')
          }
          trustedRootCertificates: useWellKnownCertificateAuthority ? null : applicationGatewayTrustedRootCertificateReferences
        }
      }
      {
        name: 'apimPoolPortalSetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 180
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'apimportalprobe')
          }
          trustedRootCertificates: useWellKnownCertificateAuthority ? null : applicationGatewayTrustedRootCertificateReferences
        }
      }
      {
        name: 'apimPoolManagementSetting'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 180
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'apimmanagementprobe')
          }
          trustedRootCertificates: useWellKnownCertificateAuthority ? null : applicationGatewayTrustedRootCertificateReferences
        }
      }
    ]
    httpListeners: [
      {
        name: 'gatewaylistener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontend1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port01')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, 'gatewaycert')
          }
          hostName: apiManagementProxyCustomHostname
          requireServerNameIndication: true
        }
      }
      {
        name: 'portallistener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontend1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port01')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, 'portalcert')
          }
          hostName: apiManagementPortalCustomHostname
          requireServerNameIndication: true
        }
      }
      {
        name: 'managementlistener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontend1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port01')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, 'managementcert')
          }
          hostName: apiManagementManagementCustomHostname
          requireServerNameIndication: true
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'gatewayrule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'gatewaylistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'gatewaybackend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'apimPoolGatewaySetting')
          }
        }
      }
      {
        name: 'portalrule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'portallistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'portalbackend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'apimPoolPortalSetting')
          }
        }
      }
      {
        name: 'managementrule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'managementlistener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'managementbackend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'apimPoolManagementSetting')
          }
        }
      }
    ]
    probes: [
      {
        name: 'apimgatewayprobe'
        properties: {
          protocol: 'Https'
          host: apiManagementProxyCustomHostname
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 120
          unhealthyThreshold: 8
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
        }
      }
      {
        name: 'apimportalprobe'
        properties: {
          protocol: 'Https'
          host: apiManagementPortalCustomHostname
          path: '/signin'
          interval: 60
          timeout: 300
          unhealthyThreshold: 8
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
        }
      }
      {
        name: 'apimmanagementprobe'
        properties: {
          protocol: 'Https'
          host: apiManagementManagementCustomHostname
          path: '/ServiceStatus'
          interval: 60
          timeout: 300
          unhealthyThreshold: 8
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
        }
      }
    ]
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20170401S'
    }
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
}

resource applicationGatewayDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGateway
  name: 'diagnosticSettings'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

// ---- Azure Key Vault ----
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: webApp.identity.tenantId
        objectId: webApp.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
  }

  resource appInsightsInstrumentationKeyKeyVaultSecret 'secrets' = {
    name: 'kvs-${baseName}-aikey'
    properties: {
      value: applicationInsights.properties.InstrumentationKey
    }
  }
}
