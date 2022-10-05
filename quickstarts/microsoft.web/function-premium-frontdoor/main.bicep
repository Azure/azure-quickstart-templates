@description('Function app name.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('Frontdoor name.')
param frontdoorName string = 'fd-${uniqueString(resourceGroup().id)}'

@description('Waf policy name.')
param wafPolicyName string = 'waf${uniqueString(resourceGroup().id)}'

@description('Message for the private link request approval.')
param frontdoorPrivateLinkRequestMessage string = 'Hi, I want to add frontdoor to functions'

@description('Function app web app plan name.')
param appPlanName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('Application Insights name.')
param appInsightsName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('Storage account name.')
param storageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('Name of the virtual network.')
param vNetName string = 'vnet-${uniqueString(resourceGroup().id)}'

@description('Name of the private endpoint.')
param privateEndpointName string = 'pve-${uniqueString(resourceGroup().id)}'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for Application Insights')
param appInsightsLocation string = resourceGroup().location

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The SKU of App Service Plan.')
param sku object = {
  Name: 'EP1'
  Tier: 'ElasticPremium'
}

var blobStoragePrivateLinkZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var filesStoragePrivateLinkZoneName = 'privatelink.file.${environment().suffixes.storage}'

// Storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountType
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

// Network
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/20'
      ]
    }
    subnets: [
      {
        name: 'data'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'function'
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: [
            {
              name: 'AzureFunctions'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }
}

resource dataSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: 'data'
  parent: vnet
}

resource functionSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: 'function'
  parent: vnet
}

// Private Endpoints
resource blobStoragePrivateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobStoragePrivateLinkZoneName
  location: 'global'
  resource blobStoragePrivateDnsVnetLink 'virtualNetworkLinks' = {
    name: 'link-${blobStoragePrivateLinkZoneName}'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource filesStoragePrivateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: filesStoragePrivateLinkZoneName
  location: 'global'
  resource filesStoragePrivateDnsVnetLink 'virtualNetworkLinks' = {
    name: 'link-${filesStoragePrivateLinkZoneName}'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource privateEndpointBlobStorage 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: '${privateEndpointName}-blob'
  location: location
  dependsOn: [
    functionSubnet
  ]
  properties: {
    subnet: {
      id: dataSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-blob'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
  resource privateEndpointBlobStorageDnsEntry 'privateDnsZoneGroups' = {
    name: blobStoragePrivateDns.name
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config1'
          properties: {
            privateDnsZoneId: blobStoragePrivateDns.id
          }
        }
      ]
    }
  }
}

resource privateEndpointFilesStorage 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: '${privateEndpointName}-files'
  location: location
  dependsOn: [
    functionSubnet
  ]
  properties: {
    subnet: {
      id: dataSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-files'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
  resource privateEndpointFilesStorageDnsEntry 'privateDnsZoneGroups' = {
    name: filesStoragePrivateDns.name
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config1'
          properties: {
            privateDnsZoneId: filesStoragePrivateDns.id
          }
        }
      ]
    }
  }
}

// App Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: appInsightsLocation
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites', functionAppName)}': 'Resource'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'IbizaWebAppExtensionCreate'
  }
}

// Function App
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appPlanName
  location: location
  sku: sku
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  dependsOn: [
    privateEndpointBlobStorage
    privateEndpointFilesStorage
  ]
  properties: {
    publicNetworkAccess: 'Disabled'
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      vnetRouteAllEnabled: true
      functionsRuntimeScaleMonitoringEnabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${reference(applicationInsights.id, '2020-02-02').InstrumentationKey};'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, '2021-09-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, '2021-09-01').keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(replace(functionAppName, '-', ''))
        }
      ]
    }
  }
}

resource functionVNetIntegration 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  name: 'virtualNetwork'
  parent: functionApp
  properties: {
    subnetResourceId: functionSubnet.id
  }
}

// Frontdoor
resource frontdoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontdoorName
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}

resource frontdoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontdoorName
  location: 'Global'
  parent: frontdoorProfile
}

resource frontdoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: location
  parent: frontdoorProfile
  properties: {
    healthProbeSettings: {
      probePath: '/'
      probeIntervalInSeconds: 120
      probeProtocol: 'Https'
      probeRequestType: 'HEAD'
    }
    loadBalancingSettings: {
      sampleSize: 4
      additionalLatencyInMilliseconds: 50
      successfulSamplesRequired: 3
    }
  }
}

resource functionOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: functionAppName
  parent: frontdoorOriginGroup
  properties: {
    hostName: '${functionAppName}.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: '${functionAppName}.azurewebsites.net'
    priority: 1
    weight: 1000
    enforceCertificateNameCheck: true
    sharedPrivateLinkResource: {
      groupId: 'sites'
      privateLinkLocation: location
      privateLink: {
         id: functionApp.id
      }
      requestMessage: frontdoorPrivateLinkRequestMessage
    }
  }
}

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: wafPolicyName
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  location: 'Global'
  properties: {
    policySettings: {
      mode: 'Prevention'
      customBlockResponseStatusCode: 403
      requestBodyCheck: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.0'
          ruleSetAction: 'Block'
        }
      ]
    }
  }
}

resource waf 'Microsoft.Cdn/profiles/securityPolicies@2021-06-01' = {
  name: 'waf-${frontdoorName}'
  parent: frontdoorProfile
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: frontdoorEndpoint.id
            }
          ]
          patternsToMatch: [
             '/*'
          ]
        }
      ]
    }
  }
}

resource frontdoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: 'default'
  parent: frontdoorEndpoint
  dependsOn: [
    functionOrigin
  ]
  properties: {
    originGroup: {
      id: frontdoorOriginGroup.id
    }
    supportedProtocols: [
      'Http' 
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    httpsRedirect: 'Enabled'
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
  } 
}
