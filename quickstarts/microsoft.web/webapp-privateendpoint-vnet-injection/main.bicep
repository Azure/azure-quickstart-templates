@description('Name of the VNet')
param virtualNetworkName string = 'vnet1'

@description('Name of the Web Farm')
param serverFarmName string = 'serverfarm'

@description('Web App 1 name must be unique DNS name worldwide')
param site1_Name string = 'webapp1-${uniqueString(resourceGroup().id)}'

@description('Web App 2 name must be unique DNS name worldwide')
param site2_Name string = 'webapp2-${uniqueString(resourceGroup().id)}'

@description('CIDR of your VNet')
param virtualNetwork_CIDR string = '10.200.0.0/16'

@description('Name of the subnet')
param subnet1Name string = 'Subnet1'

@description('Name of the subnet')
param subnet2Name string = 'Subnet2'

@description('CIDR of your subnet')
param subnet1_CIDR string = '10.200.1.0/24'

@description('CIDR of your subnet')
param subnet2_CIDR string = '10.200.2.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU name, must be minimum P1v2')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuName string = 'P1v2'

@description('SKU size, must be minimum P1v2')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuSize string = 'P1v2'

@description('SKU family, must be minimum P1v2')
@allowed([
  'P1v2'
  'P2v2'
  'P3v2'
])
param skuFamily string = 'P1v2'

@description('Name of your Private Endpoint')
param privateEndpointName string = 'PrivateEndpoint1'

@description('Link name between your Private Endpoint and your Web App')
param privateLinkConnectionName string = 'PrivateEndpointLink1'

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
        name: subnet1Name
        properties: {
          addressPrefix: subnet1_CIDR
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2_CIDR
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
}

resource webApp1 'Microsoft.Web/sites@2020-06-01' = {
  name: site1_Name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
  }
}

resource webApp2 'Microsoft.Web/sites@2020-06-01' = {
  name: site2_Name
  location: location
  kind: 'app'
  properties: {
    serverFarmId: serverFarm.id
  }
}

resource webApp2AppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webApp2
  name: 'appsettings'
  properties: {
    WEBSITE_DNS_SERVER: '168.63.129.16'
    WEBSITE_VNET_ROUTE_ALL: '1'
  }
}

resource webApp1Config 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webApp1
  name: 'web'
  properties: {
    ftpsState: 'AllAllowed'
  }
}

resource webApp2Config 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: webApp2
  name: 'web'
  properties: {
    ftpsState: 'AllAllowed'
  }
}

resource webApp1Binding 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  parent: webApp1
  name: '${webApp1.name}${webapp_dns_name}'
  properties: {
    siteName: webApp1.name
    hostNameType: 'Verified'
  }
}

resource webApp2Binding 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  parent: webApp2
  name: '${webApp2.name}${webapp_dns_name}'
  properties: {
    siteName: webApp2.name
    hostNameType: 'Verified'
  }
}

resource webApp2NetworkConfig 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: webApp2
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet2Name)
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetwork.name ,subnet1Name)
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: webApp1.id
          groupIds: [
            'sites'
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
