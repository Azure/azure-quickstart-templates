@description('Name of the VNet')
param virtualNetworkName string = 'ntier-vnet'

@description('Name of the Web Farm')
param serverFarmName string = 'serverfarm'

@description('Backend Web App name must be unique DNS name worldwide')
param backendWebAppName string = 'backend-${uniqueString(resourceGroup().id)}'

@description('Frontend Web App name must be unique DNS name worldwide')
param frontendWebAppName string = 'frontend-${uniqueString(resourceGroup().id)}'

@description('CIDR of your VNet')
param virtualNetwork_CIDR string = '10.200.0.0/16'

@description('Name of the backend subnet')
param backendSubnetName string = 'PrivateEndpointSubnet'

@description('Name of the frontend subnet')
param frontendSubnetName string = 'VnetIntegrationSubnet'

@description('CIDR of your backend subnet')
param backendSubnet_CIDR string = '10.200.1.0/24'

@description('CIDR of your frontend subnet')
param frontendSubnet_CIDR string = '10.200.2.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuName string = 'P1v2'

@description('SKU size')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuSize string = 'P1v2'

@description('SKU family')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuFamily string = 'P1v2'

@description('Name of your Private Endpoint')
param privateEndpointName string = 'PrivateEndpoint1'

@description('Name of your slot Private Endpoint')
param slotPrivateEndpointName string = 'PrivateEndpoint2'

@description('Link name between your Private Endpoint and your Web App')
param privateLinkConnectionName string = 'PrivateEndpointLink1'

@description('Link name between your Private Endpoint and your Web App slot')
param slotPrivateLinkConnectionName string = 'PrivateEndpointLink2'

var webapp_dns_name = '.azurewebsites.net'
var privateDNSZoneName = 'privatelink.azurewebsites.net'
var SKU_tier = 'PremiumV2'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork_CIDR
      ]
    }
    subnets: [
      {
        name: backendSubnetName
        properties: {
          addressPrefix: backendSubnet_CIDR
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: frontendSubnetName
        properties: {
          addressPrefix: frontendSubnet_CIDR
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: serverFarmName
  location: location
  sku: {
    name: skuName
    tier: SKU_tier
    size: skuSize
    family: skuFamily
    capacity: 1
  }
  kind: 'app'
  properties: {
    reserved: true
  }
}

resource backendWebApp 'Microsoft.Web/sites@2022-03-01' = {
  name: backendWebAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

resource backendFtpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  kind: 'string'
  parent: backendWebApp
  location: location
  properties: {
    allow: false
  }
}

resource backendScmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  kind: 'string'
  parent: backendWebApp
  location: location
  properties: {
    allow: false
  }
}

resource backendWebAppSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: '${backendWebAppName}/stage'
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
  dependsOn: [
    backendWebApp
  ]
}

resource backendSlotFtpPolicy 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  kind: 'string'
  parent: backendWebAppSlot
  location: location
  properties: {
    allow: false
  }
}

resource backendSlotScmPolicy 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  kind: 'string'
  parent: backendWebAppSlot
  location: location
  properties: {
    allow: false
  }
}

resource frontendWebApp 'Microsoft.Web/sites@2022-03-01' = {
  name: frontendWebAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, frontendSubnetName)
    vnetRouteAllEnabled: true
  }
}

resource frontendFtpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  kind: 'string'
  parent: frontendWebApp
  location: location
  properties: {
    allow: false
  }
}

resource frontendScmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  kind: 'string'
  parent: frontendWebApp
  location: location
  properties: {
    allow: false
  }
}

resource frontendWebAppSlot 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: '${frontendWebAppName}/stage'
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, frontendSubnetName)
    vnetRouteAllEnabled: true
  }
  dependsOn: [
    frontendWebApp
  ]
}

resource frontendSlotFtpPolicy 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  kind: 'string'
  parent: frontendWebAppSlot
  location: location
  properties: {
    allow: false
  }
}

resource frontendSlotScmPolicy 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  kind: 'string'
  parent: frontendWebAppSlot
  location: location
  properties: {
    allow: false
  }
}

resource backendWebAppBinding 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  parent: backendWebApp
  name: '${backendWebApp.name}${webapp_dns_name}'
  properties: {
    siteName: backendWebApp.name
    hostNameType: 'Verified'
  }
}

resource frontendWebAppBinding 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  parent: frontendWebApp
  name: '${frontendWebApp.name}${webapp_dns_name}'
  properties: {
    siteName: frontendWebApp.name
    hostNameType: 'Verified'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, backendSubnetName)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: backendWebApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource slotPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: slotPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, backendSubnetName)
    }
    privateLinkServiceConnections: [
      {
        name: slotPrivateLinkConnectionName
        properties: {
          privateLinkServiceId: backendWebApp.id
          groupIds: [
            'sites-stage'
          ]
        }
      }
    ]
  }
  dependsOn: [
    backendWebAppSlot
  ]
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZones
  name: '${privateDnsZones.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
}

resource slotPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: slotPrivateEndpoint
  name: 'slotdnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config2'
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
}
