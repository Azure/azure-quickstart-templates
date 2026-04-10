// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { getAppTags, getPublisherTags, HubAppConfig, HubAppFeature, HubCoreConfig, newAppConfig } from 'hub-types.bicep'


//==============================================================================
// Parameters
//==============================================================================

// @description('Required. Name of the FinOps hub instance.')
// param hubName string

// @description('Required. Minimum version number supported by the FinOps hub app.')
// param hubMinVersion string

// @description('Required. Maximum version number supported by the FinOps hub app.')
// param hubMaxVersion string

@description('Required. Display name of the FinOps hub app publisher.')
param publisher string

@description('Required. Namespace to use for the FinOps hub app publisher. Will be combined with appName to form a fully-qualified identifier. Must be an alphanumeric string without spaces or special characters except for periods. This value should never change and will be used to uniquely identify the publisher. A change would require migrating content to the new publisher. Namespace + appName + telemetryString must be 50 characters or less - additional characters will be trimmed.')
param namespace string

@description('Required. Unique identifier of the FinOps hub app within the publisher namespace. Must be an alphanumeric string without spaces or special characters. This name should never change and will be used with the namespace to fully qualify the app. A change would require migrating content to the new app. Namespace + appName + telemetryString must be 50 characters or less - additional characters will be trimmed.')
param appName string

@description('Required. Display name of the FinOps hub app.')
param displayName string

@description('Optional. Version number of the FinOps hub app.')
param appVersion string = ''

@description('Optional. Indicate which features the app requires. Allowed values: "Storage". Default: [] (none).')
param features HubAppFeature[] = []

@description('Optional. Custom string with additional metadata to log. Must an alphanumeric string without spaces or special characters except for underscores and dashes. Namespace + appName + telemetryString must be 50 characters or less - additional characters will be trimmed.')
param telemetryString string = ''

@description('Optional. Enable telemetry to track anonymous module usage trends, monitor for bugs, and improve future releases.')
param enableDefaultTelemetry bool = true

//------------------------------------------------------------------------------
// Temporary parameters that should be removed in the future
//------------------------------------------------------------------------------

// TODO: Pull deployment config from the cloud
@description('Required. FinOps hub coreConfig.')
param coreConfig HubCoreConfig


//==============================================================================
// Variables
//==============================================================================

var appConfig = newAppConfig(coreConfig, publisher, namespace, appName, displayName, appVersion)

// Features
var usesStorage = contains(features, 'Storage')

// App telemetry
var telemetryId = 'ftk-hubapp-${appConfig.app.name}${empty(telemetryString) ? '' : '_'}${telemetryString}'  // cSpell:ignore hubapp
var telemetryProps = {
  mode: 'Incremental'
  template: {
    '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
    contentVersion: '1.0.0.0'
    metadata: {
      _generator: {
        name: 'FTK: ${publisher} - ${displayName} ${telemetryId}'
        version: appVersion
      }
    }
    resources: []
  }
}


//==============================================================================
// Resources
//==============================================================================

// TODO: Get hub instance to verify version compatibility

//------------------------------------------------------------------------------
// Telemetry
// Used to anonymously count the number of times the template has been deployed
// and to track and fix deployment bugs to ensure the highest quality.
// No information about you or your cost data is collected.
//------------------------------------------------------------------------------

resource appTelemetry 'Microsoft.Resources/deployments@2022-09-01' = if (enableDefaultTelemetry) {
  name: length(telemetryId) <= 64 ? telemetryId : substring(telemetryId, 0, 64)
  tags: getAppTags(appConfig, 'Microsoft.Resources/deployments', true)
  properties: telemetryProps
}

//------------------------------------------------------------------------------
// TODO: Get hub details
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Storage account
//------------------------------------------------------------------------------

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (usesStorage) {
  name: appConfig.publisher.storage
  location: coreConfig.hub.location
  sku: {
    name: coreConfig.storage.sku
  }
  kind: 'BlockBlobStorage'
  tags: getPublisherTags(appConfig, 'Microsoft.Storage/storageAccounts')
  properties: union(!coreConfig.storage.isInfrastructureEncrypted ? {} : {
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: coreConfig.storage.isInfrastructureEncrypted
    }
  }, {
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: coreConfig.network.isPrivate ? 'Deny' : 'Allow'
    }
  })
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = if (coreConfig.network.isPrivate) {
  name: 'privatelink.blob.${environment().suffixes.storage}'  // cSpell:ignore privatelink
}

resource blobEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (coreConfig.network.isPrivate) {
  name: '${storageAccount.name}-blob-ep'
  location: coreConfig.hub.location
  tags: getPublisherTags(appConfig, 'Microsoft.Network/privateEndpoints')
  properties: {
    subnet: {
      id: coreConfig.network.subnets.storage
    }
    privateLinkServiceConnections: [
      {
        name: 'blobLink'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }

  resource blobPrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'storage-endpoint-zone'
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

resource dfsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = if (coreConfig.network.isPrivate) {
  name: 'privatelink.dfs.${environment().suffixes.storage}'  // cSpell:ignore privatelink
}

resource dfsEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (coreConfig.network.isPrivate) {
  name: '${storageAccount.name}-dfs-ep'
  location: coreConfig.hub.location
  tags: getPublisherTags(appConfig, 'Microsoft.Network/privateEndpoints')
  properties: {
    subnet: {
      id: coreConfig.network.subnets.storage
    }
    privateLinkServiceConnections: [
      {
        name: 'dfsLink'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['dfs']
        }
      }
    ]
  }

  resource dfsPrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'dfs-endpoint-zone'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: dfsPrivateDnsZone.name
          properties: {
            privateDnsZoneId: dfsPrivateDnsZone.id
          }
        }
      ]
    }
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('FinOps hub app configuration.')
output config HubAppConfig = appConfig
