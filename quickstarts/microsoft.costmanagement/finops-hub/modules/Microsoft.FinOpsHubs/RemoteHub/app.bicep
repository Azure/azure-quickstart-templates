// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { finOpsToolkitVersion, HubAppProperties, privateRoutingForLinkedServices, isSupportedVersion } from '../../fx/hub-types.bicep'
import { AppMetadata as CoreMetadata } from '../Core/metadata.bicep'

metadata hubApp = {
  id: 'Microsoft.FinOpsHubs.RemoteHub'
  version: '15.0'
  dependencies: ['Microsoft.FinOpsHubs.Core']
}


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app getting deployed.')
param app HubAppProperties

@description('Required. Create and store a key for a remote storage account.')
@secure()
param remoteStorageKey string

@description('Required. Remote storage account for ingestion dataset.')
param remoteHubStorageUri string

@description('Required. Metadata describing shared resources from the Core app. Must be v13 or higher.')
@validate(x => isSupportedVersion(x.version, '13.0', ''), 'Remote hubs require FinOps hubs version 13.0 or higher.')
param core CoreMetadata


//==============================================================================
// Variables
//==============================================================================

var storageKeySecretName = '${toLower(app.hub.name)}-storage-key'


//==============================================================================
// Resources
//==============================================================================

// App registration
module appRegistration '../../fx/hub-app.bicep' = {
  name: 'Microsoft.FinOpsHubs.RemoteHub_Register'
  params: {
    app: app
    version: finOpsToolkitVersion
    features: [
      'DataFactory'
      'KeyVault'
      'Storage'
    ]
  }
}

// Key Vault secret
module keyVault_secret '../../fx/hub-vault.bicep' = {
  name: 'keyVault_secret'
  dependsOn: [appRegistration]  // Wait for Key Vault to be created
  params: {
    vaultName: app.keyVault
    secretName: storageKeySecretName
    secretValue: remoteStorageKey
    secretExpirationInSeconds: 1702648632
    secretNotBeforeInSeconds: 10000
  }
}

// Get key vault instance
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: app.keyVault
  dependsOn: [appRegistration]  // Wait for Key Vault to be created
}

// Get data factory instance
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: app.dataFactory
  dependsOn: [appRegistration]  // Wait for Key Vault to be created

  // cSpell:ignore linkedservices
  resource linkedService_remoteHubStorage 'linkedservices' = {
    name: 'remoteHubStorage'
    properties: {
      annotations: []
      parameters: {}
      type: 'AzureBlobFS'
      typeProperties: {
        url: remoteHubStorageUri
        accountKey: {
          type: 'AzureKeyVaultSecret'
          store: {
            // TODO: Should the key vault linked service name/reference be part of hub settings?
            referenceName: keyVault.name
            type: 'LinkedServiceReference'
          }
          secretName: storageKeySecretName
        }
      }
      ...privateRoutingForLinkedServices(app.hub)
    }
  }

  // Replace the ingestion dataset
  resource dataset_ingestion 'datasets' = {
    name: core.datasets.ingestion
    properties: {
      annotations: []
      parameters: {
        blobPath: {
          type: 'String'
        }
      }
      type: 'Parquet'
      typeProperties: {
        location: {
          type: 'AzureBlobFSLocation'
          fileName: {
            value: '@{dataset().blobPath}'
            type: 'Expression'
          }
          fileSystem: core.containers.ingestion
        }
      }
      linkedServiceName: {
        parameters: {}
        referenceName: linkedService_remoteHubStorage.name
        type: 'LinkedServiceReference'
      }
    }
  }

  // Replace the ingestion_files dataset
  resource dataset_ingestion_files 'datasets' = {
    name: core.datasets.ingestionFiles
    properties: {
      annotations: []
      parameters: {
        folderPath: {
          type: 'String'
        }
      }
      type: 'Parquet'
      typeProperties: {
        location: {
          type: 'AzureBlobFSLocation'
          fileSystem: core.containers.ingestion
          folderPath: {
            value: '@dataset().folderPath'
            type: 'Expression'
          }
        }
      }
      linkedServiceName: {
        parameters: {}
        referenceName: linkedService_remoteHubStorage.name
        type: 'LinkedServiceReference'
      }
    }
  }

  // Replace the ingestion_manifest dataset to write manifests to remote hub
  resource dataset_ingestion_manifest 'datasets' = {
    name: core.datasets.ingestionManifest
    properties: {
      annotations: []
      parameters: {
        fileName: {
          type: 'String'
          defaultValue: 'manifest.json'
        }
        folderPath: {
          type: 'String'
          defaultValue: core.containers.ingestion
        }
      }
      type: 'Json'
      typeProperties: {
        location: {
          type: 'AzureBlobFSLocation'
          fileName: {
            value: '@{dataset().fileName}'
            type: 'Expression'
          }
          folderPath: {
            value: '@{dataset().folderPath}'
            type: 'Expression'
          }
        }
      }
      linkedServiceName: {
        parameters: {}
        referenceName: linkedService_remoteHubStorage.name
        type: 'LinkedServiceReference'
      }
    }
  }
}


//==============================================================================
// Outputs
//==============================================================================
