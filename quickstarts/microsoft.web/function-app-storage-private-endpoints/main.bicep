@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the Azure Function app.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('The name of the Azure Function hosting plan.')
param functionAppPlanName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('Specifies the OS used for the Azure Function hosting plan.')
@allowed([
  'Windows'
  'Linux'
])
param functionPlanOS string = 'Windows'

@description('Specifies the Azure Function hosting plan SKU.')
@allowed([
  'EP1'
  'EP2'
  'EP3'
])
param functionAppPlanSku string = 'EP1'

@description('The name of the backend Azure storage account used by the Azure Function app.')
param functionStorageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('The name of the virtual network for virtual network integration.')
param vnetName string = 'vnet-${uniqueString(resourceGroup().id)}'

@description('The name of the virtual network subnet to be associated with the Azure Function app.')
param functionSubnetName string = 'snet-func'

@description('The name of the virtual network subnet used for allocating IP addresses for private endpoints.')
param privateEndpointSubnetName string = 'snet-pe'

@description('The IP adddress space used for the virtual network.')
param vnetAddressPrefix string = '10.100.0.0/16'

@description('The IP address space used for the Azure Function integration subnet.')
param functionSubnetAddressPrefix string = '10.100.0.0/24'

@description('The IP address space used for the private endpoints.')
param privateEndpointSubnetAddressPrefix string = '10.100.1.0/24'

var applicationInsightsName = 'appi-${uniqueString(resourceGroup().id)}'

var privateStorageFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var privateEndpointStorageFileName = '${storageAccount.name}-file-private-endpoint'

var privateStorageTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var privateEndpointStorageTableName = '${storageAccount.name}-table-private-endpoint'

var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateEndpointStorageBlobName = '${storageAccount.name}-blob-private-endpoint'

var privateStorageQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var privateEndpointStorageQueueName = '${storageAccount.name}-queue-private-endpoint'

var functionContentShareName = 'function-content-share'

// The term "reserved" is used by ARM to indicate if the hosting plan is a Linux or Windows-based plan.
// A value of true indicated Linux, while a value of false indicates Windows.
// See https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=json#appserviceplanproperties-object.
var isReserved = (functionPlanOS == 'Linux') ? true : false

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
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
        name: functionSubnetName
        properties: {
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          delegations: [
            {
              name: 'webapp'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          addressPrefix: functionSubnetAddressPrefix
        }
      }
      {
        name: privateEndpointSubnetName
        properties: {
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          addressPrefix: privateEndpointSubnetAddressPrefix
        }
      }
    ]
  }

  resource functionSubnet 'subnets' existing = {
    name: functionSubnetName
  }

  resource privateEndpointSubnet 'subnets' existing = {
    name: privateEndpointSubnetName
  }
}

// -- Private DNS Zones --
resource storageFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageFileDnsZoneName
  location: 'global'

  resource storageFileDnsZoneLink 'virtualNetworkLinks' = {
    name: '${storageFileDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

resource storageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'

  resource storageBlobDnsZoneLink 'virtualNetworkLinks' = {
    name: '${storageBlobDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

resource storageQueueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageQueueDnsZoneName
  location: 'global'

  resource storageQueueDnsZoneLink 'virtualNetworkLinks' = {
    name: '${storageQueueDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

resource storageTableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageTableDnsZoneName
  location: 'global'

  resource storageTableDnsZoneLink 'virtualNetworkLinks' = {
    name: '${storageTableDnsZone.name}-link'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetwork.id
      }
    }
  }
}

// -- Private Endpoints --
resource storageFilePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageFileName
  location: location
  properties: {
    subnet: {
      id: virtualNetwork::privateEndpointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageFilePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }

  resource storageFilePrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'filePrivateDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: storageFileDnsZone.id
          }
        }
      ]
    }
  }
}

resource storageTablePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageTableName
  location: location
  properties: {
    subnet: {
      id: virtualNetwork::privateEndpointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageTablePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
  }

  resource storageTablePrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'tablePrivateDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: storageTableDnsZone.id
          }
        }
      ]
    }
  }
}

resource storageQueuePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageQueueName
  location: location
  properties: {
    subnet: {
      id: virtualNetwork::privateEndpointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
  }

  resource storageQueuePrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'queuePrivateDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: storageQueueDnsZone.id
          }
        }
      ]
    }
  }
}

resource storageBlobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: privateEndpointStorageBlobName
  location: location
  properties: {
    subnet: {
      id: virtualNetwork::privateEndpointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageBlobPrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }

  resource storageBlobPrivateEndpointDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'blobPrivateDnsZoneGroup'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config'
          properties: {
            privateDnsZoneId: storageBlobDnsZone.id
          }
        }
      ]
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: functionStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
  }
}

resource functionContentShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccount.name}/default/${functionContentShareName}'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource plan 'Microsoft.Web/serverfarms@2021-01-01' = {
  location: location
  name: functionAppPlanName
  sku: {
    name: functionAppPlanSku
    tier: 'ElasticPremium'
    size: functionAppPlanSku
    family: 'EP'
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 20
    reserved: isReserved
  }
}

resource functionApp 'Microsoft.Web/sites@2021-01-01' = {
  location: location
  name: functionAppName
  kind: isReserved ? 'functionapp,linux' : 'functionapp'
  properties: {
    httpsOnly: true
    serverFarmId: plan.id
    reserved: isReserved
    virtualNetworkSubnetId: virtualNetwork::functionSubnet.id
    siteConfig: {
      vnetRouteAllEnabled: true
      functionsRuntimeScaleMonitoringEnabled: true
      linuxFxVersion: isReserved ? 'dotnet|3.1' : json('null')
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
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
          value: functionContentShareName
        }
      ]
    }
  }

  resource config 'config' = {
    name: 'web'
    properties: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}
