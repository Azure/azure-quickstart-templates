@description('Name of the VNet')
param virtualNetworkName string = 'ntier-vnet'

@description('Name of the Web Farm')
param serverFarmName string = 'serverfarm'

@description('Backend Web App name must be unique DNS name worldwide')
param webAppNameBackend string = 'backend-${uniqueString(resourceGroup().id)}'

@description('Frontend Web App name must be unique DNS name worldwide')
param webAppNameFrontend string = 'frontend-${uniqueString(resourceGroup().id)}'

@description('CIDR of your VNet')
param virtualNetworkCidr string = '10.200.0.0/16'

@description('Name of the backend subnet')
param subnetNamePrivateEndpoint string = 'PrivateEndpointSubnet'

@description('Name of the frontend subnet')
param subnetNameVnetIntegration string = 'VnetIntegrationSubnet'

@description('CIDR of your backend subnet')
param subnetCidrPrivateEndpoint string = '10.200.1.0/24'

@description('CIDR of your frontend subnet')
param subnetCidrVnetIntegration string = '10.200.2.0/24'

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
param privateEndpointSlotName string = 'PrivateEndpoint2'

@description('Link name between your Private Endpoint and your Web App')
param privateLinkConnectionName string = 'PrivateEndpointLink1'

@description('Link name between your Private Endpoint and your Web App slot')
param privateLinkConnectionSlotName string = 'PrivateEndpointLink2'

var webappDnsName = '.azurewebsites.net'
var privateDNSZoneName = 'privatelink.azurewebsites.net'
var skuTier = 'PremiumV2'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkCidr
      ]
    }
    subnets: [
      {
        name: subnetNamePrivateEndpoint
        properties: {
          addressPrefix: subnetCidrPrivateEndpoint
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: subnetNameVnetIntegration
        properties: {
          addressPrefix: subnetCidrVnetIntegration
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
    tier: skuTier
    size: skuSize
    family: skuFamily
    capacity: 1
  }
  kind: 'app'
  properties: {
    reserved: true
  }
}

resource webAppBackend 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppNameBackend
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

resource ftpPolicyBackend 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: location
  kind: 'string'
  parent: webAppBackend
  properties: {
    allow: false
  }
}

resource scmPolicyBackend 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: location
  kind: 'string'
  parent: webAppBackend
  properties: {
    allow: false
  }
}

resource webAppSlotBackend 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: '${webAppNameBackend}/stage'
  location: location
  kind: 'app'
  dependsOn: [
    webAppBackend
  ]
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

resource ftpPolicySlotBackend 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: location
  kind: 'string'
  parent: webAppSlotBackend
  properties: {
    allow: false
  }
}

resource scmPolicySlotBackend 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: location
  kind: 'string'
  parent: webAppSlotBackend
  properties: {
    allow: false
  }
}

resource webAppFrontend 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppNameFrontend
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnetNameVnetIntegration)
    vnetRouteAllEnabled: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

resource ftpPolicyFrontend 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: location
  kind: 'string'
  parent: webAppFrontend
  properties: {
    allow: false
  }
}

resource scmPolicyFrontend 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: location
  kind: 'string'
  parent: webAppFrontend
  properties: {
    allow: false
  }
}

resource webAppSlotFrontend 'Microsoft.Web/sites/slots@2022-03-01' = {
  name: '${webAppNameFrontend}/stage'
  location: location
  kind: 'app'
  dependsOn: [
    webAppFrontend
  ]
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    virtualNetworkSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnetNameVnetIntegration)
    vnetRouteAllEnabled: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

resource ftpPolicySlotFrontend 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  location: location
  kind: 'string'
  parent: webAppSlotFrontend
  properties: {
    allow: false
  }
}

resource scmPolicySlotFrontend 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  location: location
  kind: 'string'
  parent: webAppSlotFrontend
  properties: {
    allow: false
  }
}

resource webAppBindingBackend 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  name: '${webAppBackend.name}${webappDnsName}'
  parent: webAppBackend
  properties: {
    siteName: webAppBackend.name
    hostNameType: 'Verified'
  }
}

resource webAppBindingFrontend 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  name: '${webAppFrontend.name}${webappDnsName}'
  parent: webAppFrontend
  properties: {
    siteName: webAppFrontend.name
    hostNameType: 'Verified'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnetNamePrivateEndpoint)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: webAppBackend.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateEndpointSlot 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointSlotName
  location: location
  dependsOn: [
    webAppSlotBackend
  ]
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, subnetNamePrivateEndpoint)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionSlotName
        properties: {
          privateLinkServiceId: webAppBackend.id
          groupIds: [
            'sites-stage'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${privateDnsZones.name}-link'
  parent: privateDnsZones
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: 'dnsgroupname'
  parent: privateEndpoint
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

resource privateDnsZoneGroupSlot 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  name: 'slotdnsgroupname'
  parent: privateEndpointSlot
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
