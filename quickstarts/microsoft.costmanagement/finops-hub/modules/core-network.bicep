// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { getHubTags, HubCoreConfig } from 'hub-types.bicep'


//==============================================================================
// Parameters
//==============================================================================

// @description('Required. Name of the FinOps hub instance.')
// param hubName string

@description('Required. FinOps hub configuration settings.')
param coreConfig HubCoreConfig


//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Storage DNS zones
//------------------------------------------------------------------------------

// Required for the Azure portal and Storage Explorer
resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (coreConfig.network.isPrivate) {
  name: coreConfig.network.dnsZones.blob.name
  location: 'global'
  tags: getHubTags(coreConfig, 'Microsoft.Storage/privateDnsZones')
  properties: {}

  resource blobPrivateDnsZoneLink 'virtualNetworkLinks' = {
    name: '${replace(blobPrivateDnsZone.name, '.', '-')}-link'
    location: 'global'
    tags: getHubTags(coreConfig, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks')
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: coreConfig.network.id
      }
    }
  }
}

// Required for Power BI
resource dfsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (coreConfig.network.isPrivate) {
  name: coreConfig.network.dnsZones.dfs.name
  location: 'global'
  tags: getHubTags(coreConfig, 'Microsoft.Storage/privateDnsZones')
  properties: {}

  resource dfsPrivateDnsZoneLink 'virtualNetworkLinks' = {
    name: '${replace(dfsPrivateDnsZone.name, '.', '-')}-link'
    location: 'global'
    tags: getHubTags(coreConfig, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks')
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: coreConfig.network.id
      }
    }
  }
}

// Required for Azure Data Explorer
resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (coreConfig.network.isPrivate) {
  name: coreConfig.network.dnsZones.queue.name
  location: 'global'
  tags: getHubTags(coreConfig, 'Microsoft.Storage/privateDnsZones')
  properties: {}
  
  resource queuePrivateDnsZoneLink 'virtualNetworkLinks' = {
    name: '${replace(queuePrivateDnsZone.name, '.', '-')}-link'
    location: 'global'
    tags: getHubTags(coreConfig, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks')
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: coreConfig.network.id
      }
    }
  }
}

// Required for Azure Data Explorer
resource tablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (coreConfig.network.isPrivate) {
  name: coreConfig.network.dnsZones.table.name
  location: 'global'
  tags: getHubTags(coreConfig, 'Microsoft.Storage/privateDnsZones')
  properties: {}
  
  resource tablePrivateDnsZoneLink 'virtualNetworkLinks' = {
    name: '${replace(tablePrivateDnsZone.name, '.', '-')}-link'
    location: 'global'
    tags: getHubTags(coreConfig, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks')
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: coreConfig.network.id
      }
    }
  }
}

//------------------------------------------------------------------------------
// Script storage
//------------------------------------------------------------------------------

resource scriptStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (coreConfig.network.isPrivate) {
  name: coreConfig.deployment.storage
  location: coreConfig.hub.location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: getHubTags(coreConfig, 'Microsoft.Storage/storageAccounts')
  properties: {
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: true
    isHnsEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: coreConfig.network.subnets.scripts
          action: 'Allow'
        }
      ]
    }
  }
}

resource scriptEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (coreConfig.network.isPrivate) {
  name: '${scriptStorageAccount.name}-blob-ep'
  location: coreConfig.hub.location
  tags: getHubTags(coreConfig, 'Microsoft.Network/privateEndpoints')
  properties: {
    subnet: {
      id: coreConfig.network.subnets.storage
    }
    privateLinkServiceConnections: [
      {
        name: 'scriptLink'
        properties: {
          privateLinkServiceId: scriptStorageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
  
  resource scriptPrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'blob-endpoint-zone'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: blobPrivateDnsZone.name
          properties: {
            privateDnsZoneId: blobPrivateDnsZone.id
          }
        }
      ]
    }
  }
}


//==============================================================================
// Output
//==============================================================================

output config HubCoreConfig = coreConfig
