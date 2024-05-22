// Creates Azure dependent resources for Azure AI studio

@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Tags to add to the resources')
param tags object = {}

@description('AI services name')
param aiServicesName string

@description('Application Insights resource name')
param applicationInsightsName string

@description('Container registry name')
param containerRegistryName string

@description('The name of the Key Vault')
param keyvaultName string

@description('Subnet Id to deploy into.')
param subnetResourceId string

@description('Resource group name of the virtual network to deploy the resource into.')
param vnetRgName string

@description('Resource Id of the virtual network to deploy the resource into.')
param vnetResourceId string

var containerRegistryNameCleaned = replace(containerRegistryName, '-', '')

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: false
    ImmediatePurgeDataOn30Days: true
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
    Request_Source: 'rest'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryNameCleaned
  location: location
  tags: tags
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
    }
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 7
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Disabled'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyvaultName
  location: location
  tags: tags
  properties: {
    createMode: 'default'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}

@description('Name of the storage account')
param storageName string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])

@description('Storage SKU')
param storageSkuName string = 'Standard_LRS'

var storageNameCleaned = replace(storageName, '-', '')

resource aiServices 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: aiServicesName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices' // or 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: subnetResourceId
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
      ipRules: []
    }
    customSubDomainName: aiServicesName
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageNameCleaned
  location: location
  tags: tags
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Disabled'
  }
}

resource storagePrivateEndpointBlob 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: '${storageNameCleaned}-blob-pe'
  location: location
  properties: {
    subnet: {
      id: subnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: 'blob'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource storagePrivateEndpointFile 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: '${storageNameCleaned}-file-pe'
  location: location
  properties: {
    subnet: {
      id: subnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: 'file'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

module privateDnsDeployment './storage/private-dns.bicep' = {
  name: '${storageNameCleaned}-DNS'
  scope: resourceGroup(subscription().subscriptionId, vnetRgName)
  params: {}
  dependsOn: [
    storagePrivateEndpointBlob
    storagePrivateEndpointFile
  ]
}

module virtualNetworkLink './storage/virtual-network-link.bicep' = {
  name: '${storageNameCleaned}-VirtualNetworkLink'
  scope: resourceGroup(subscription().subscriptionId, vnetRgName)
  params: {
    virtualNetworkId: vnetResourceId
  }
  dependsOn: [
    privateDnsDeployment
  ]
}

module dnsZoneGroup './storage/dns-zone-group.bicep' = {
  name: '${storageNameCleaned}-dnsZoneGroup'
  scope: resourceGroup()
  params: {
    vnetRgName: vnetRgName
    privateEndpointNameBlob: '${storageNameCleaned}-blob-pe'
    privateEndpointNameFile: '${storageNameCleaned}-file-pe'
    location: location
  }
  dependsOn: [
    storagePrivateEndpointBlob
    storagePrivateEndpointFile
    privateDnsDeployment
  ]
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${storageNameCleaned}-identity'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storage.id, managedIdentity.id, 'Storage Blob Data Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: managedIdentity.properties.principalId
    scope: resourceGroup().id
  }
}

output aiservicesID string = aiServices.id
output aiservicesTarget string = aiServices.properties.endpoint
output storageId string = storage.id
output keyvaultId string = keyVault.id
output containerRegistryId string = containerRegistry.id
output applicationInsightsId string = applicationInsights.id
