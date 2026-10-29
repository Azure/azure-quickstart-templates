// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { getAppPublisherTags, HubAppProperties, HubAppFeature } from 'hub-types.bicep'


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app getting deployed.')
param app HubAppProperties

@description('Required. Version number of the FinOps hub app.')
param version string

// @description('Required. Minimum version number supported by the FinOps hub app.')
// param hubMinVersion string

// @description('Required. Maximum version number supported by the FinOps hub app.')
// param hubMaxVersion string

@description('Optional. Indicate which features the app requires. Allowed values: "DataFactory", "KeyVault", "Storage". Default: [] (none).')
param features HubAppFeature[] = []

@description('Optional. Indicate which RBAC roles the Data Factory identity needs on the publisher storage account. This is in addition to Storage Blob Data Contributor for reading and managing content, which is granted to apps that use the "Storage" feature. Roles are assigned whether or not the app uses the "Storage" feature since the storage account is shared across all apps from the same publisher. Default: [] (none).')
param storageRoles string[] = []

@description('Optional. Custom string with additional metadata to log. Must an alphanumeric string without spaces or special characters except for underscores and dashes. Namespace + appName + telemetryString must be 50 characters or less - additional characters will be trimmed.')
param telemetryString string = ''


//==============================================================================
// Variables
//==============================================================================

// Features
var usesDataFactory = contains(features, 'DataFactory')
var usesKeyVault = contains(features, 'KeyVault')
var usesStorage = contains(features, 'Storage')

// App telemetry
var telemetryId = 'ftk-hubapp-${app.id}${empty(telemetryString) ? '' : '_'}${telemetryString}'  // cSpell:ignore hubapp
var telemetryProps = {
  mode: 'Incremental'
  template: {
    '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
    contentVersion: '1.0.0.0'
    metadata: {
      _generator: {
        name: 'FTK: ${app.id}'
        version: version
      }
    }
    resources: []
  }
}

// Roles needed for Data Factory management (trigger start/stop, pipeline dispatch)
var factoryManagementRoles = [
  // Data Factory contributor -- https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#data-factory-contributor
  // Used to start/stop triggers, delete old pipelines/triggers, and execute pipelines via REST API
  '673868aa-7521-48a0-acc6-0f60742d39f5'
]

// Roles for ADF to manage data in storage
// Does not include roles assignments needed against the export scope
// The data management roles are only granted to apps that use the "Storage" feature; roles requested via storageRoles are always granted
var factoryStorageRoles = union(storageRoles, !usesStorage ? [] : [
  // Storage Account Contributor -- https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-account-contributor
  // Used to move files from the msexports to ingestion container
  '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  // Storage Blob Data Contributor -- https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  // Reader -- https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#reader
  'acdd72a7-3385-48ef-bd42-f606fba81ae7'
])

// Storage infrastructure encryption
var storageInfrastructureEncryptionProperties = !app.hub.options.storageInfrastructureEncryption ? {} : {
  encryption: {
    keySource: 'Microsoft.Storage'
    requireInfrastructureEncryption: app.hub.options.storageInfrastructureEncryption
  }
}

// KeyVault access policies
var keyVaultAccessPolicies = [
  {
    #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
    objectId: dataFactory.identity.principalId
    tenantId: subscription().tenantId
    permissions: { secrets: ['get'] }
  }
]


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

resource appTelemetry 'Microsoft.Resources/deployments@2022-09-01' = if (app.hub.options.enableTelemetry) {
  name: length(telemetryId) <= 64 ? telemetryId : substring(telemetryId, 0, 64)
  tags: getAppPublisherTags(app, 'Microsoft.Resources/deployments')
  properties: telemetryProps
}

//------------------------------------------------------------------------------
// Data Factory
//------------------------------------------------------------------------------

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = if (usesDataFactory) {
  name: app.dataFactory
  location: app.hub.location
  tags: getAppPublisherTags(app, 'Microsoft.DataFactory/factories')
  identity: { type: 'SystemAssigned' }
  properties: any({ // Using any() to hide the error that gets surfaced because globalConfigurations is not in the ADF schema yet
      globalConfigurations: {
        PipelineBillingEnabled: 'true'
      }
  })

  resource managedVirtualNetwork 'managedVirtualNetworks' = if (app.hub.options.privateRouting) {
    name: 'default'
    properties: {}

    resource storageManagedPrivateEndpoint 'managedPrivateEndpoints' = if (usesStorage) {
      name: storageAccount.name
      properties: {
        #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
        name: storageAccount.name
        groupId: 'dfs'
        #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
        privateLinkResourceId: storageAccount.id
        fqdns: [
          #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
          storageAccount.properties.primaryEndpoints.dfs
        ]
      }
    }

    resource keyVaultManagedPrivateEndpoint 'managedPrivateEndpoints' = if (usesKeyVault) {
      #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
      name: keyVault.name
      properties: {
        #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
        name: keyVault.name
        groupId: 'vault'
        #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
        privateLinkResourceId: keyVault.id
        fqdns: [
          #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
          keyVault.properties.vaultUri
        ]
      }
    }
  }

  resource managedIntegrationRuntime 'integrationRuntimes' = if (app.hub.options.privateRouting) {
    name: 'ManagedIntegrationRuntime'
    
    properties: {
      type: 'Managed'
      managedVirtualNetwork: {
        referenceName: dataFactory::managedVirtualNetwork.name
        type: 'ManagedVirtualNetworkReference'
      }
      typeProperties: {
        computeProperties: {
          location: app.hub.location
          dataFlowProperties: {
            computeType: 'General'
            coreCount: 8
            timeToLive: 10
            cleanup: false
            customProperties: []
          }
          copyComputeScaleProperties: {
            dataIntegrationUnit: 16
            timeToLive: 30
          }
          pipelineExternalComputeScaleProperties: {
            timeToLive: 30
            numberOfPipelineNodes: 1
            numberOfExternalNodes: 1
          }
        }
      }
    }
  }

  // cSpell:ignore linkedservices
  resource linkedService_keyVault 'linkedservices' = if (usesKeyVault) {
    name: keyVault.name
    dependsOn: app.hub.options.privateRouting ? [managedIntegrationRuntime] : []
    properties: {
      annotations: []
      parameters: {}
      type: 'AzureKeyVault'
      typeProperties: {
        baseUrl: reference('Microsoft.KeyVault/vaults/${keyVault.name}', '2023-02-01').vaultUri
      }
      connectVia: app.hub.options.privateRouting
        ? {
            referenceName: managedIntegrationRuntime.name
            type: 'IntegrationRuntimeReference'
          }
        : null
    }
  }

  resource linkedService_storageAccount 'linkedservices' = if (usesStorage) {
    name: storageAccount.name
    dependsOn: app.hub.options.privateRouting ? [managedIntegrationRuntime] : []
    properties: {
      annotations: []
      parameters: {}
      type: 'AzureBlobFS'
      typeProperties: {
        url: reference('Microsoft.Storage/storageAccounts/${storageAccount.name}', '2021-08-01').primaryEndpoints.dfs
      }
      connectVia: app.hub.options.privateRouting
        ? {
            referenceName: managedIntegrationRuntime.name
            type: 'IntegrationRuntimeReference'
          }
        : null
    }
  }
}

// TODO: Consolidate keyVaultEndpoints.bicep into hub-app.bicep
module getKeyVaultPrivateEndpointConnections 'keyVaultEndpoints.bicep' = if (usesDataFactory && usesKeyVault && app.hub.options.privateRouting) {
  name: 'GetKeyVaultPrivateEndpointConnections'
  dependsOn: [
    dataFactory::managedVirtualNetwork::keyVaultManagedPrivateEndpoint
    getStoragePrivateEndpointConnections  // Queue Key Vault private endpoints after storage since we can only run one deployment at a time with private endpoints
  ]
  params: {
    keyVaultName: keyVault.name
  }
}

module approveKeyVaultPrivateEndpointConnections 'keyVaultEndpoints.bicep' = if (usesDataFactory && usesKeyVault && app.hub.options.privateRouting) {
  name: 'ApproveKeyVaultPrivateEndpointConnections'
  params: {
    keyVaultName: keyVault.name
    #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
    privateEndpointConnections: getKeyVaultPrivateEndpointConnections.outputs.privateEndpointConnections
  }
}

// TODO: Consolidate storageEndpoints.bicep into hub-app.bicep
module getStoragePrivateEndpointConnections 'storageEndpoints.bicep' = if (usesDataFactory && usesStorage && app.hub.options.privateRouting) {
  name: 'GetStoragePrivateEndpointConnections'
  dependsOn: [
    dataFactory::managedVirtualNetwork::storageManagedPrivateEndpoint
    stopTriggers  // Queue storage private endpoints after triggers are stopped since we can only run one deployment at a time with private endpoints
  ]
  params: {
    storageAccountName: storageAccount.name
  }
}

module approveStoragePrivateEndpointConnections 'storageEndpoints.bicep' = if (usesDataFactory && usesStorage && app.hub.options.privateRouting) {
  name: 'ApproveStoragePrivateEndpointConnections'
  params: {
    storageAccountName: storageAccount.name
    #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
    privateEndpointConnections: getStoragePrivateEndpointConnections.outputs.privateEndpointConnections
  }
}

//------------------------------------------------------------------------------
// Role assignments
//------------------------------------------------------------------------------

// Grant ADF identity access to storage
// The storage account is shared across all apps from the same publisher, so apps that request roles via storageRoles are granted them even when they do not create the storage account themselves
resource storageRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in factoryStorageRoles: if (usesDataFactory) {
    name: guid(storageAccount.id, role, dataFactory.id)
    scope: storageAccount
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      #disable-next-line BCP318 // Null safety warning for conditional resource access
      principalId: dataFactory.identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

// Grant ADF identity access to execute its own pipelines (e.g., for dynamic pipeline dispatch via REST API)
resource factorySelfRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in factoryManagementRoles: if (usesDataFactory) {
    name: guid(dataFactory.id, role, dataFactory.id)
    scope: dataFactory
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      #disable-next-line BCP318 // Null safety warning for conditional resource access
      principalId: dataFactory.identity.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

//------------------------------------------------------------------------------
// Stop triggers and delete old resources
//------------------------------------------------------------------------------

// Create managed identity to start/stop triggers
resource triggerManagerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (usesDataFactory) {
  name: '${dataFactory.name}_triggerManager'
  location: app.hub.location
  tags: union(app.tags, app.hub.tagsByResource[?'Microsoft.ManagedIdentity/userAssignedIdentities'] ?? {})
}

resource triggerManagerRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in factoryManagementRoles: if (usesDataFactory) {
    name: guid(dataFactory.id, role, triggerManagerIdentity.id)
    scope: dataFactory
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
      principalId: triggerManagerIdentity.properties.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

// Stop all triggers before deploying triggers
module stopTriggers 'hub-deploymentScript.bicep' = if (usesDataFactory) {
  name: '${app.publisher}.${app.name}_ADF.StopTriggers'
  dependsOn: [
    // TODO: Do we need to make this optional only if private endpoints are enabled and telemetry is enabled? Will it fail when telemetry is disabled?
    appTelemetry  // Ensure the telemetry deployment is run before stopping triggers since we can only run one deployment at a time with private endpoints
    triggerManagerRoleAssignments
  ]
  params: {
    app: app
    identityName: triggerManagerIdentity.name
    scriptContent: loadTextContent('./scripts/Init-DataFactory.ps1')
    arguments: join([
      '-DataFactoryResourceGroup "${resourceGroup().name}"'
      '-DataFactoryName "${dataFactory.name}"'
      '-StopTriggers'
    ], ' ')
  }
}

//------------------------------------------------------------------------------
// Storage account
//------------------------------------------------------------------------------

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (usesStorage) {
  name: app.storage
  location: app.hub.location
  sku: {
    name: app.hub.options.storageSku
  }
  kind: 'BlockBlobStorage'
  tags: getAppPublisherTags(app, 'Microsoft.Storage/storageAccounts')
  properties: {
    ...storageInfrastructureEncryptionProperties
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: app.hub.options.privateRouting ? 'Deny' : 'Allow'
    }
  }

  resource blobService 'blobServices' = {
    name: 'default'
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = if (usesStorage && app.hub.options.privateRouting) {
  name: 'privatelink.blob.${environment().suffixes.storage}'  // cSpell:ignore privatelink
}

resource blobEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (usesStorage && app.hub.options.privateRouting) {
  name: '${storageAccount.name}-blob-ep'
  location: app.hub.location
  tags: getAppPublisherTags(app, 'Microsoft.Network/privateEndpoints')
  properties: {
    subnet: {
      id: app.hub.routing.subnets.storage
    }
    privateLinkServiceConnections: [
      {
        name: 'blobLink'
        properties: {
          #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
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

resource dfsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = if (usesStorage && app.hub.options.privateRouting) {
  name: 'privatelink.dfs.${environment().suffixes.storage}'  // cSpell:ignore privatelink
}

resource dfsEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (usesStorage && app.hub.options.privateRouting) {
  name: '${storageAccount.name}-dfs-ep'
  location: app.hub.location
  tags: getAppPublisherTags(app, 'Microsoft.Network/privateEndpoints')
  properties: {
    subnet: {
      id: app.hub.routing.subnets.storage
    }
    privateLinkServiceConnections: [
      {
        name: 'dfsLink'
        properties: {
          #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
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

//------------------------------------------------------------------------------
// KeyVault for secrets
//------------------------------------------------------------------------------

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = if (usesKeyVault) {
  name: app.keyVault
  location: app.hub.location
  tags: getAppPublisherTags(app, 'Microsoft.KeyVault/vaults')
  properties: {
    sku: any({
      name: app.hub.options.keyVaultSku
      family: 'A'
    })
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    // Use null instead of false when purge protection is disabled - Azure requires null to indicate the property should not be set
    enablePurgeProtection: app.hub.options.keyVaultEnablePurgeProtection ? true : null
    enableRbacAuthorization: false
    createMode: 'default'
    tenantId: subscription().tenantId
    accessPolicies: keyVaultAccessPolicies
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: app.hub.options.privateRouting ? 'Deny' : 'Allow'
    }
  }
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (usesKeyVault && app.hub.options.privateRouting) {
  name: 'privatelink${replace(environment().suffixes.keyvaultDns, 'vault', 'vaultcore')}'  // cSpell:ignore privatelink, vaultcore
  location: 'global'
  tags: getAppPublisherTags(app, 'Microsoft.Network/privateDnsZones')
  properties: {}

  resource keyVaultPrivateDnsZoneLink 'virtualNetworkLinks@2024-06-01' = {
    name: '${replace(keyVaultPrivateDnsZone.name, '.', '-')}-link'
    location: 'global'
    tags: getAppPublisherTags(app, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks')
    properties: {
      virtualNetwork: {
        id: app.hub.routing.networkId
      }
      registrationEnabled: false
    }
  }
}

resource keyVaultEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (usesKeyVault && app.hub.options.privateRouting) {
  name: '${keyVault.name}-ep'
  location: app.hub.location
  tags: getAppPublisherTags(app, 'Microsoft.Network/privateEndpoints')
  properties: {
    subnet: {
      id: app.hub.routing.subnets.keyVault
    }
    privateLinkServiceConnections: [
      {
        name: 'keyVaultLink'
        properties: {
          #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }

  resource keyVaultPrivateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'keyvault-endpoint-zone'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: keyVaultPrivateDnsZone.name
          properties: {
            privateDnsZoneId: keyVaultPrivateDnsZone.id
          }
        }
      ]
    }
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('Resource ID of the Data Factory instance used by the FinOps hub app. Empty when not deployed.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output dataFactoryId string = usesDataFactory ? dataFactory.id : ''

@description('Resource ID of the Key Vault instance used by the FinOps hub app. Empty when not deployed.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output keyVaultId string = usesKeyVault ? keyVault.id : ''

@description('Resource ID of the storage account instance used by the FinOps hub app. Empty when not deployed.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output storageAccountId string = usesStorage ? storageAccount.id : ''

@description('Principal ID for the managed identity used by Data Factory. Empty when not deployed.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output principalId string = usesDataFactory ? dataFactory.identity.principalId : ''

@description('Name of the managed identity used to create and stop ADF triggers. Empty when not deployed.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output triggerManagerIdentityName string = usesDataFactory ? triggerManagerIdentity.name : ''
