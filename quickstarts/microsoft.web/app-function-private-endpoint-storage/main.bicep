@description('Function app name.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('Function app web app plan name.')
param appPlanName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('Application Insights name.')
param appInsightsName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('Storage account name.')
param storageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('Name of the virtual network.')
param vNetName string = 'vnet-${uniqueString(resourceGroup().id)}'

@description('Name of the private endpoint.')
param privateEndpointName string = 'vnet-${uniqueString(resourceGroup().id)}'

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

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appPlanName
  location: location
  sku: sku
}

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

resource blobStoragePrivateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobStoragePrivateLinkZoneName
  location: 'global'
}

resource blobStoragePrivateDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'link-${blobStoragePrivateLinkZoneName}'
  parent: blobStoragePrivateDns
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateEndpointBlobStorage 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
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
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateEndpointBlobStorageDnsEntry 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: blobStoragePrivateDns.name
  parent: privateEndpointBlobStorage
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

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource functionVNetIntegration 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  name: 'virtualNetwork'
  parent: functionApp
  properties: {
    subnetResourceId: functionSubnet.id
  }
}

resource appsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, '2021-09-01').keys[0].value}'
    APPINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${reference(applicationInsights.id, '2020-02-02').InstrumentationKey};'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    minTlsVersion: '1.2'
    WEBSITE_DNS_SERVER: '168.63.129.16'
  }
}
