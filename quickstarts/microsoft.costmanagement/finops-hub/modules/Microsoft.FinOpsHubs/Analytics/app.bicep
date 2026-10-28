// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { finOpsToolkitVersion, HubAppProperties, privateRoutingForLinkedServices, isSupportedVersion } from '../../fx/hub-types.bicep'
import { AppMetadata as CoreMetadata } from '../Core/metadata.bicep'
import { AppMetadata as AnalyticsMetadata } from './metadata.bicep'

metadata hubApp = {
  id: 'Microsoft.FinOpsHubs.Analytics'
  version: '15.0'
  dependencies: ['Microsoft.FinOpsHubs.Core']
  metadata: 'https://microsoft.github.io/finops-toolkit/deploy/finops-hub/15.0/Microsoft.FinOpsHubs/Analytics/metadata.bicep'
}


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app getting deployed.')
param app HubAppProperties

@description('Required. Metadata describing shared resources from the Core app. Must be v13 or higher.')
@validate(x => isSupportedVersion(x.version, '13.0', ''), 'FinOps hubs Analytics requires FinOps hubs version 13.0 or higher.')
param core CoreMetadata

@description('Optional. Name of the Azure Data Explorer cluster to use for advanced analytics. If empty, Azure Data Explorer will not be deployed. Required to use with Power BI if you have more than $2-5M/mo in costs being monitored. Default: "" (do not use).')
@maxLength(22)
param clusterName string = ''

// https://learn.microsoft.com/azure/templates/microsoft.kusto/clusters?pivots=deployment-language-bicep#azuresku
@description('Optional. Name of the Azure Data Explorer SKU. Default: "Dev(No SLA)_Standard_E2a_v4".')
@allowed([
  'Dev(No SLA)_Standard_E2a_v4' // 2 CPU, 16GB RAM, 24GB cache, $110/mo
  'Dev(No SLA)_Standard_D11_v2' // 2 CPU, 14GB RAM, 78GB cache, $121/mo
  'Standard_D11_v2'             // 2 CPU, 14GB RAM, 78GB cache, $245/mo
  'Standard_D12_v2'
  'Standard_D13_v2'
  'Standard_D14_v2'
  'Standard_D16d_v5'
  'Standard_D32d_v4'
  'Standard_D32d_v5'
  'Standard_DS13_v2+1TB_PS'
  'Standard_DS13_v2+2TB_PS'
  'Standard_DS14_v2+3TB_PS'
  'Standard_DS14_v2+4TB_PS'
  'Standard_E2a_v4'            // 2 CPU, 14GB RAM, 78GB cache, $220/mo
  'Standard_E2ads_v5'
  'Standard_E2d_v4'
  'Standard_E2d_v5'
  'Standard_E4a_v4'
  'Standard_E4ads_v5'
  'Standard_E4d_v4'
  'Standard_E4d_v5'
  'Standard_E8a_v4'
  'Standard_E8ads_v5'
  'Standard_E8as_v4+1TB_PS'
  'Standard_E8as_v4+2TB_PS'
  'Standard_E8as_v5+1TB_PS'
  'Standard_E8as_v5+2TB_PS'
  'Standard_E8d_v4'
  'Standard_E8d_v5'
  'Standard_E8s_v4+1TB_PS'
  'Standard_E8s_v4+2TB_PS'
  'Standard_E8s_v5+1TB_PS'
  'Standard_E8s_v5+2TB_PS'
  'Standard_E16a_v4'
  'Standard_E16ads_v5'
  'Standard_E16as_v4+3TB_PS'
  'Standard_E16as_v4+4TB_PS'
  'Standard_E16as_v5+3TB_PS'
  'Standard_E16as_v5+4TB_PS'
  'Standard_E16d_v4'
  'Standard_E16d_v5'
  'Standard_E16s_v4+3TB_PS'
  'Standard_E16s_v4+4TB_PS'
  'Standard_E16s_v5+3TB_PS'
  'Standard_E16s_v5+4TB_PS'
  'Standard_E64i_v3'
  'Standard_E80ids_v4'
  'Standard_EC8ads_v5'
  'Standard_EC8as_v5+1TB_PS'
  'Standard_EC8as_v5+2TB_PS'
  'Standard_EC16ads_v5'
  'Standard_EC16as_v5+3TB_PS'
  'Standard_EC16as_v5+4TB_PS'
  'Standard_L4s'
  'Standard_L8as_v3'
  'Standard_L8s'
  'Standard_L8s_v2'
  'Standard_L8s_v3'
  'Standard_L16as_v3'
  'Standard_L16s'
  'Standard_L16s_v2'
  'Standard_L16s_v3'
  'Standard_L32as_v3'
  'Standard_L32s_v3'
])
param clusterSku string = 'Dev(No SLA)_Standard_E2a_v4'

@description('Optional. Number of nodes to use in the cluster. Allowed values: 1 for the Basic SKU tier and 2-1000 for Standard. Default: 1 for dev/test SKUs, 2 for standard SKUs.')
@minValue(1)
@maxValue(1000)
param clusterCapacity int = 1

// TODO: Figure out why this is breaking upgrades
// @description('Optional. Array of external tenant IDs that should have access to the cluster. Default: empty (no external access).')
// param clusterTrustedExternalTenants string[] = []

// cSpell:ignore eventhouse
@description('Optional. Microsoft Fabric eventhouse query URI. Default: "" (do not use).')
param fabricQueryUri string = ''

@description('Optional. Number of capacity units for the Microsoft Fabric capacity. This is the number in your Fabric SKU (e.g., Trial = 1, F2 = 2, F64 = 64). This is used to manage parallelization in data pipelines. If you change capacity, please redeploy the template. Allowed values: 1 for the Fabric trial and 2-2048 based on the assigned Fabric capacity (e.g., F2-F2048). Default: 2.')
@minValue(1)
@maxValue(2048)
param fabricCapacityUnits int = 2

@description('Optional. Forces the table to be updated if different from the last time it was deployed.')
param forceUpdateTag string = utcNow()

@description('Optional. If true, ingestion will continue even if some rows fail to ingest. Default: false.')
param continueOnErrors bool = false

@description('Required. Number of days of data to retain in the Data Explorer *_raw tables.')
param rawRetentionInDays int


//==============================================================================
// Variables
//==============================================================================

var HUB_DATA_EXPLORER = 'hubDataExplorer'
var HUB_DB = 'Hub'
var INGESTION_DB = 'Ingestion'

var ftkGitTag = loadTextContent('../../fx/ftktag.txt')  // cSpell:ignore ftktag
var ftkReleaseUri = indexOf(finOpsToolkitVersion, '-dev') != -1
  ? 'https://raw.githubusercontent.com/microsoft/finops-toolkit/refs/heads/dev/src/open-data'
  : 'https://raw.githubusercontent.com/microsoft/finops-toolkit/refs/tags/${ftkGitTag}/src/open-data'

var useFabric = !empty(fabricQueryUri)
var useAzure = !useFabric && !empty(clusterName)

// cSpell:ignore ftkver, privatelink
var dataExplorerDnsSuffixLookup = {
  AzureCloud: 'kusto.windows.net'
  AzureUSGovernment: 'kusto.usgovcloudapi.net'
  AzureChinaCloud: 'kusto.windows.cn'
}
var dataExplorerDnsSuffix = dataExplorerDnsSuffixLookup[?environment().name] ?? replace(environment().suffixes.storage, 'core', 'kusto')
var dataExplorerPrivateDnsZoneName = replace('privatelink.${app.hub.location}.${dataExplorerDnsSuffix}', '..', '.')

// Actual = Minimum(ClusterMaximumConcurrentOperations, Number of nodes in cluster * Maximum(1, Core count per node * CoreUtilizationCoefficient))
var ingestionCapacity = {
  'Dev(No SLA)_Standard_E2a_v4': 1
  'Dev(No SLA)_Standard_D11_v2': 1
  Standard_D11_v2: 2
  Standard_D12_v2: 4
  Standard_D13_v2: 8
  Standard_D14_v2: 16
  Standard_D16d_v5: 16
  Standard_D32d_v4: 32
  Standard_D32d_v5: 32
  'Standard_DS13_v2+1TB_PS': 8
  'Standard_DS13_v2+2TB_PS': 8
  'Standard_DS14_v2+3TB_PS': 16
  'Standard_DS14_v2+4TB_PS': 16
  Standard_E2a_v4: 2
  Standard_E2ads_v5: 2
  Standard_E2d_v4: 2
  Standard_E2d_v5: 2
  Standard_E4a_v4: 4
  Standard_E4ads_v5: 4
  Standard_E4d_v4: 4
  Standard_E4d_v5: 4
  Standard_E8a_v4: 8
  Standard_E8ads_v5: 8
  'Standard_E8as_v4+1TB_PS': 8
  'Standard_E8as_v4+2TB_PS': 8
  'Standard_E8as_v5+1TB_PS': 8
  'Standard_E8as_v5+2TB_PS': 8
  Standard_E8d_v4: 8
  Standard_E8d_v5: 8
  'Standard_E8s_v4+1TB_PS': 8
  'Standard_E8s_v4+2TB_PS': 8
  'Standard_E8s_v5+1TB_PS': 8
  'Standard_E8s_v5+2TB_PS': 8
  Standard_E16a_v4: 16
  Standard_E16ads_v5: 16
  'Standard_E16as_v4+3TB_PS': 16
  'Standard_E16as_v4+4TB_PS': 16
  'Standard_E16as_v5+3TB_PS': 16
  'Standard_E16as_v5+4TB_PS': 16
  Standard_E16d_v4: 16
  Standard_E16d_v5: 16
  'Standard_E16s_v4+3TB_PS': 16
  'Standard_E16s_v4+4TB_PS': 16
  'Standard_E16s_v5+3TB_PS': 16
  'Standard_E16s_v5+4TB_PS': 16
  Standard_E64i_v3: 64
  Standard_E80ids_v4: 80
  Standard_EC8ads_v5: 8
  'Standard_EC8as_v5+1TB_PS': 8
  'Standard_EC8as_v5+2TB_PS': 8
  Standard_EC16ads_v5: 16
  'Standard_EC16as_v5+3TB_PS': 16
  'Standard_EC16as_v5+4TB_PS': 16
  Standard_L4s: 4
  Standard_L8as_v3: 8
  Standard_L8s: 8
  Standard_L8s_v2: 8
  Standard_L8s_v3: 8
  Standard_L16as_v3: 16
  Standard_L16s: 16
  Standard_L16s_v2: 16
  Standard_L16s_v3: 16
  Standard_L32as_v3: 32
  Standard_L32s_v3: 32
}

var dataExplorerIngestionCapacity = useFabric
  ? fabricCapacityUnits
  : (!useAzure ? 1 : ingestionCapacity[?clusterSku] ?? 1)

// WORKAROUND: Direct property access fails on cluster updates due to ARM bug
// See: https://github.com/Azure/azure-resource-manager-templates/issues/[issue-number]
var dataExplorerUri = useFabric ? fabricQueryUri : 'https://${cluster.name}.${app.hub.location}.${dataExplorerDnsSuffix}'

//==============================================================================
// Resources
//==============================================================================

// App registration
module appRegistration '../../fx/hub-app.bicep' = {
  name: 'Microsoft.FinOpsHubs.Analytics_Register'
  params: {
    app: app
    version: finOpsToolkitVersion
    features: [
      'DataFactory'
      'Storage'
    ]
  }
}

//------------------------------------------------------------------------------
// Dependencies
//------------------------------------------------------------------------------

// Get data factory instance
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: app.dataFactory
  dependsOn: [
    appRegistration
  ]
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  dependsOn: [
    appRegistration
  ]
}

resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: 'privatelink.queue.${environment().suffixes.storage}'
  dependsOn: [
    appRegistration
  ]
}

resource tablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: 'privatelink.table.${environment().suffixes.storage}'
  dependsOn: [
    appRegistration
  ]
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: app.storage
  dependsOn: [
    appRegistration
  ]
}

//------------------------------------------------------------------------------
// Cluster + databases
//------------------------------------------------------------------------------

//  Kusto cluster
resource cluster 'Microsoft.Kusto/clusters@2023-08-15' = if (useAzure) {
  name: replace(clusterName, '_', '-')
  dependsOn: [
    appRegistration
  ]
  location: app.hub.location
  tags: union(app.tags, app.hub.tagsByResource[?'Microsoft.Kusto/clusters'] ?? {})
  sku: {
    name: clusterSku
    tier: startsWith(clusterSku, 'Dev(No SLA)_') ? 'Basic' : 'Standard'
    capacity: startsWith(clusterSku, 'Dev(No SLA)_') ? 1 : (clusterCapacity == 1 ? 2 : clusterCapacity)
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableStreamingIngest: true
    enableAutoStop: false
    publicNetworkAccess: app.hub.options.privateRouting ? 'Disabled' : 'Enabled'
    // TODO: Figure out why this is breaking upgrades
    // trustedExternalTenants: [for tenantId in clusterTrustedExternalTenants: {
    //     value: tenantId
    // }]
  }

  resource adfClusterAdmin 'principalAssignments' = {
    name: 'adf-mi-cluster-admin'
    properties: {
      principalType: 'App'
      principalId: dataFactory.identity.principalId
      tenantId: dataFactory.identity.tenantId
      role: 'AllDatabasesAdmin'
    }
  }

  resource ingestionDb 'databases' = {
    name: INGESTION_DB
    location: app.hub.location
    kind: 'ReadWrite'
  }

  resource hubDb 'databases' = {
    name: HUB_DB
    location: app.hub.location
    kind: 'ReadWrite'
  }
}

module ingestion_OpenDataInternalScripts '../../fx/hub-database.bicep' = if (useAzure) {
  name: 'Microsoft.FinOpsHubs.Analytics_ADX.IngestionOpenDataInternal'
  params: {
    clusterName: cluster.name
    databaseName: cluster::ingestionDb.name
    scripts: {
      OpenDataFunctions_resource_type_1: loadTextContent('scripts/OpenDataFunctions_resource_type_1.kql')
      OpenDataFunctions_resource_type_2: loadTextContent('scripts/OpenDataFunctions_resource_type_2.kql')
      OpenDataFunctions_resource_type_3: loadTextContent('scripts/OpenDataFunctions_resource_type_3.kql')
      OpenDataFunctions_resource_type_4: loadTextContent('scripts/OpenDataFunctions_resource_type_4.kql')
      OpenDataFunctions_resource_type_5: loadTextContent('scripts/OpenDataFunctions_resource_type_5.kql')
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module ingestion_InitScripts '../../fx/hub-database.bicep' = if (useAzure) {
  name: 'Microsoft.FinOpsHubs.Analytics_ADX.IngestionInit'
  dependsOn: [
    ingestion_OpenDataInternalScripts
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::ingestionDb.name
    scripts: {
      openData: loadTextContent('scripts/OpenDataFunctions.kql')
      common: loadTextContent('scripts/Common.kql')
      infra: loadTextContent('scripts/IngestionSetup_HubInfra.kql')
      rawTables: replace(loadTextContent('scripts/IngestionSetup_RawTables.kql'), '$$rawRetentionInDays$$', string(rawRetentionInDays))
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module ingestion_VersionedScripts '../../fx/hub-database.bicep' = if (useAzure) {
  name: 'Microsoft.FinOpsHubs.Analytics_ADX.IngestionVersioned'
  dependsOn: [
    ingestion_InitScripts
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::ingestionDb.name
    scripts: {
      v1_0: loadTextContent('scripts/IngestionSetup_v1_0.kql')
      v1_2: loadTextContent('scripts/IngestionSetup_v1_2.kql')
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module hub_InitScripts '../../fx/hub-database.bicep' = if (useAzure) {
  name: 'Microsoft.FinOpsHubs.Analytics_ADX.HubInit'
  dependsOn: [
    ingestion_InitScripts
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::hubDb.name
    scripts: {
      common: loadTextContent('scripts/Common.kql')
      openData: loadTextContent('scripts/HubSetup_OpenData.kql')
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module hub_VersionedScripts '../../fx/hub-database.bicep' = if (useAzure) {
  name: 'Microsoft.FinOpsHubs.Analytics_ADX.HubVersioned'
  dependsOn: [
    ingestion_VersionedScripts
    hub_InitScripts
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::hubDb.name
    scripts: {
      v1_0: loadTextContent('scripts/HubSetup_v1_0.kql')
      v1_2: loadTextContent('scripts/HubSetup_v1_2.kql')
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module hub_LatestScripts '../../fx/hub-database.bicep' = if (useAzure) {
  name: 'Microsoft.FinOpsHubs.Analytics_ADX.HubLatest'
  dependsOn: [
    hub_VersionedScripts
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::hubDb.name
    scripts: {
      latest: loadTextContent('scripts/HubSetup_Latest.kql')
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

// Authorize Kusto Cluster to read storage
resource clusterStorageAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (useAzure) {
  name: guid(cluster.name, subscription().id, 'Storage Blob Data Contributor')
  scope: storage
  properties: {
    description: 'Give "Storage Blob Data Contributor" to the cluster'
    #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
    principalId: cluster.identity.principalId
    // Required in case principal not ready when deploying the assignment
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'  // Storage Blob Data Contributor -- https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage
    )
  }
}

// DNS zone
resource dataExplorerPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (useAzure && app.hub.options.privateRouting) {
  name: dataExplorerPrivateDnsZoneName
  location: 'global'
  tags: union(app.tags, app.hub.tagsByResource[?'Microsoft.Network/privateDnsZones'] ?? {})
  properties: {}
}

// Link DNS zone to VNet
resource dataExplorerPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (useAzure && app.hub.options.privateRouting) {
  name: '${replace(dataExplorerPrivateDnsZone.name, '.', '-')}-link'
  location: 'global'
  parent: dataExplorerPrivateDnsZone
  tags: union(app.tags, app.hub.tagsByResource[?'Microsoft.Network/privateDnsZones/virtualNetworkLinks'] ?? {})
  properties: {
    virtualNetwork: {
      id: app.hub.routing.networkId
    }
    registrationEnabled: false
  }
}

// Private endpoint
// Kusto rejects concurrent cluster writes with ServiceIsInMaintenance, so private endpoint changes wait for the database scripts
resource dataExplorerEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (useAzure && app.hub.options.privateRouting) {
  name: '${cluster.name}-ep'
  dependsOn: [
    hub_LatestScripts
  ]
  location: app.hub.location
  tags: union(app.tags, app.hub.tagsByResource[?'Microsoft.Network/privateEndpoints'] ?? {})
  properties: {
    subnet: {
      id: app.hub.routing.subnets.dataExplorer
    }
    privateLinkServiceConnections: [
      {
        name: 'dataExplorerLink'
        properties: {
          privateLinkServiceId: cluster.id
          groupIds: ['cluster']
        }
      }
    ]
  }
}

// DNS records for private endpoint
resource dataExplorerPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (useAzure && app.hub.options.privateRouting) {
  name: 'dataExplorer-endpoint-zone'
  parent: dataExplorerEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-westus-kusto-net'
        properties: {
          privateDnsZoneId: dataExplorerPrivateDnsZone.id
        }
      }
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
      {
        name: 'privatelink-table-core-windows-net'
        properties: {
          privateDnsZoneId: tablePrivateDnsZone.id
        }
      }
      {
        name: 'privatelink-queue-core-windows-net'
        properties: {
          privateDnsZoneId: queuePrivateDnsZone.id
        }
      }
    ]
  }
}

//------------------------------------------------------------------------------
// Data Factory setup
// cSpell:ignore linkedservices
//------------------------------------------------------------------------------

resource dataFactoryVNet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' existing = if (useAzure && app.hub.options.privateRouting) {
  name: 'default'
  parent: dataFactory

  resource dataExplorerManagedPrivateEndpoint 'managedPrivateEndpoints' = {
    name: HUB_DATA_EXPLORER
    dependsOn: [
      dataExplorerEndpoint
    ]
    properties: {
      name: HUB_DATA_EXPLORER
      groupId: 'cluster'
      #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
      privateLinkResourceId: cluster.id
      fqdns: [
        'https://${cluster.name}.${app.hub.location}.${dataExplorerDnsSuffix}'
      ]
    }
  }
}

module getDataExplorerPrivateEndpointConnections 'dataExplorerEndpoints.bicep' = if (useAzure && app.hub.options.privateRouting) {
  name: 'GetDataExplorerPrivateEndpointConnections'
  dependsOn: [
    dataFactoryVNet::dataExplorerManagedPrivateEndpoint
  ]
  params: {
    dataExplorerName: cluster.name
  }
}

module approveDataExplorerPrivateEndpointConnections 'dataExplorerEndpoints.bicep' = if (useAzure && app.hub.options.privateRouting) {
  name: 'ApproveDataExplorerPrivateEndpointConnections'
  params: {
    #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
    dataExplorerName: cluster.name
    #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access
    privateEndpointConnections: getDataExplorerPrivateEndpointConnections.outputs.privateEndpointConnections
  }
}

// ADX/Fabric linked service
resource linkedService_dataExplorer 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (useAzure || useFabric) {
  name: HUB_DATA_EXPLORER
  parent: dataFactory
  properties: {
    type: 'AzureDataExplorer'
    parameters: {
      database: {
        type: 'String'
        defaultValue: INGESTION_DB
      }
    }
    typeProperties: {
      endpoint: dataExplorerUri
      database: '@{linkedService().database}'
      tenant: dataFactory.identity.tenantId
      servicePrincipalId: dataFactory.identity.principalId
    }
    ...privateRoutingForLinkedServices(app.hub)
  }
}

// GitHub repository linked service for FTK release files
resource linkedService_ftkRepo 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'ftkRepo'
  parent: dataFactory
  properties: {
    type: 'HttpServer'
    typeProperties: {
      url: 'https://github.com/microsoft/finops-toolkit/'
      enableServerCertificateValidation: true
      authenticationType: 'Anonymous'
    }
    ...privateRoutingForLinkedServices(app.hub)
  }
}

resource dataset_dataExplorer 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: HUB_DATA_EXPLORER
  parent: dataFactory
  properties: {
    type: 'AzureDataExplorerTable'
    linkedServiceName: {
      parameters: {
        database: '@dataset().database'
      }
      referenceName: linkedService_dataExplorer.name
      type: 'LinkedServiceReference'
    }
    parameters: {
      database: {
        type: 'String'
        defaultValue: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
      }
      table: { type: 'String' }
    }
    typeProperties: {
      table: {
        value: '@dataset().table'
        type: 'Expression'
      }
    }
  }
}

resource dataset_ftkReleaseFile 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'ftkReleaseFile'
  parent: dataFactory
  properties: {
    linkedServiceName: {
      referenceName: linkedService_ftkRepo.name
      type: 'LinkedServiceReference'
    }
    parameters: {
      fileName: {
        type: 'string'
      }
      version: {
        type: 'string'
        defaultValue: ftkGitTag  // Must match the tag, not a major.minor version (e.g., 13, not 13.0)
      }
    }
    annotations: []
    type: 'DelimitedText'
    typeProperties: {
      location: {
        type: 'HttpServerLocation'
        relativeUrl: {
          value: '@concat(\'releases/download/v\', dataset().version, \'/\', dataset().fileName)'
          type: 'Expression'
        }
      }
      columnDelimiter: ','
      escapeChar: '\\'
      firstRowAsHeader: true
      quoteChar: '"'
    }
    schema: []
  }
}

module trigger_IngestionManifestAdded '../../fx/hub-eventTrigger.bicep' = {
  name: 'Microsoft.FinOpsHubs.Core_IngestionManifestAddedTrigger'
  params: {
    dataFactoryName: dataFactory.name
    triggerName: '${core.containers.ingestion}_ManifestAdded'

    // TODO: Replace pipeline with event: 'Microsoft.FinOpsHubs.Core.IngestionManifestAdded'
    pipelineName: pipeline_ExecuteIngestionETL.name
    pipelineParameters: {
      folderPath: '@triggerBody().folderPath'
    }

    storageAccountName: app.storage
    storageContainer: core.containers.ingestion
    storagePathEndsWith: 'manifest.json'
  }
}

//------------------------------------------------------------------------------
// config_InitializeHub pipeline
//------------------------------------------------------------------------------
@description('Initializes the hub instance based on the configuration settings.')
resource pipeline_InitializeHub 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${core.datasets.config}_InitializeHub'
  parent: dataFactory
  properties: {
    activities: [
      { // Get Config
        name: 'Get Config'
        type: 'Lookup'
        dependsOn: []
        policy: {
          timeout: '0.00:05:00'
          retry: 2
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'JsonSource'
            storeSettings: {
              type: 'AzureBlobFSReadSettings'
              recursive: true
              enablePartitionDiscovery: false
            }
            formatSettings: {
              type: 'JsonReadSettings'
            }
          }
          dataset: {
            referenceName: core.datasets.config
            type: 'DatasetReference'
          }
        }
      }
      { // Set Version
        name: 'Set Version'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Get Config'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'version'
          value: {
            value: '@activity(\'Get Config\').output.firstRow.version'
            type: 'Expression'
          }
        }
      }
      { // Set Scopes
        name: 'Set Scopes'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Get Config'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'scopes'
          value: {
            value: '@string(activity(\'Get Config\').output.firstRow.scopes)'
            type: 'Expression'
          }
        }
      }
      { // Set Retention
        name: 'Set Retention'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Get Config'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'retention'
          value: {
            value: '@string(activity(\'Get Config\').output.firstRow.retention)'
            type: 'Expression'
          }
        }
      }
      { // Until Capacity Is Available
        name: 'Until Capacity Is Available'
        type: 'Until'
        dependsOn: [
          {
            activity: 'Set Version'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Scopes'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Retention'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@equals(variables(\'tryAgain\'), false)'
            type: 'Expression'
          }
          activities: [
            { // Confirm Ingestion Capacity
              name: 'Confirm Ingestion Capacity'
              type: 'AzureDataExplorerCommand'
              dependsOn: []
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                // cSpell:ignore Ingestions
                command: '.show capacity | where Resource == \'Ingestions\' | project Remaining'
                commandTimeout: '00:20:00'
              }
              linkedServiceName: {
                referenceName: linkedService_dataExplorer.name
                type: 'LinkedServiceReference'
                parameters: {
                  database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                }
              }
            }
            { // If Has Capacity
              name: 'If Has Capacity'
              type: 'IfCondition'
              dependsOn: [
                {
                  activity: 'Confirm Ingestion Capacity'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              userProperties: []
              typeProperties: {
                expression: {
                  value: '@or(equals(activity(\'Confirm Ingestion Capacity\').output.count, 0), greater(activity(\'Confirm Ingestion Capacity\').output.value[0].Remaining, 0))'
                  type: 'Expression'
                }
                ifFalseActivities: [
                  { // Wait for Ingestion
                    name: 'Wait for Ingestion'
                    type: 'Wait'
                    dependsOn: []
                    userProperties: []
                    typeProperties: {
                      waitTimeInSeconds: 15
                    }
                  }
                  { // Try Again
                    name: 'Try Again'
                    type: 'SetVariable'
                    dependsOn: [
                      {
                        activity: 'Wait for Ingestion'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      variableName: 'tryAgain'
                      value: true
                    }
                  }
                ]
                ifTrueActivities: [
                  { // Save ingestion policy in ADX
                    name: 'Set ingestion policy in ADX'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: []
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      command: {
                        // Do not attempt to set the ingestion policy if using Fabric; use a simple query as a placeholder
                        value: useFabric
                          ? '.show database ${INGESTION_DB} policy managed_identity'
                          #disable-next-line BCP318 // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access // Null safety warning for conditional resource access
                          : '.alter-merge database ${INGESTION_DB} policy managed_identity "[ { \'ObjectId\' : \'${cluster.identity.principalId}\', \'AllowedUsages\' : \'NativeIngestion\' }]"'
                        type: 'Expression'
                      }
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Save Hub Settings in ADX
                    name: 'Save Hub Settings in ADX'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: [
                      {
                        activity: 'Set ingestion policy in ADX'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      command: {
                        // cSpell:ignore isnull, isnotempty
                        value: '@concat(\'.append HubSettingsLog <| print version="\', variables(\'version\'), \'",scopes=dynamic(\', variables(\'scopes\'), \'),retention=dynamic(\', variables(\'retention\'), \') | extend scopes = iff(isnull(scopes[0]), pack_array(scopes), scopes) | mv-apply scopeObj = scopes on (where isnotempty(scopeObj.scope) | summarize scopes = make_set(scopeObj.scope))\')'
                        type: 'Expression'
                      }
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Update PricingUnits in ADX
                    name: 'Update PricingUnits in ADX'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: [
                      {
                        activity: 'Save Hub Settings in ADX'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      // cSpell:ignore externaldata
                      command: '.set-or-replace PricingUnits <| externaldata(x_PricingUnitDescription: string, AccountTypes: string, x_PricingBlockSize: real, PricingUnit: string)[@"${ftkReleaseUri}/PricingUnits.csv"] with (format="csv", ignoreFirstRecord=true) | project-away AccountTypes'
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Update Regions in ADX
                    name: 'Update Regions in ADX'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: [
                      {
                        activity: 'Update PricingUnits in ADX'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      command: '.set-or-replace Regions <| externaldata(ResourceLocation: string, RegionId: string, RegionName: string)[@"${ftkReleaseUri}/Regions.csv"] with (format="csv", ignoreFirstRecord=true)'
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Update ResourceTypes in ADX
                    name: 'Update ResourceTypes in ADX'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: [
                      {
                        activity: 'Update Regions in ADX'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      command: '.set-or-replace ResourceTypes <| externaldata(x_ResourceType: string, SingularDisplayName: string, PluralDisplayName: string, LowerSingularDisplayName: string, LowerPluralDisplayName: string, IsPreview: bool, Description: string, IconUri: string, Links: string)[@"${ftkReleaseUri}/ResourceTypes.csv"] with (format="csv", ignoreFirstRecord=true) | project-away Links'
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Update Services in ADX
                    name: 'Update Services in ADX'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: [
                      {
                        activity: 'Update ResourceTypes in ADX'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      command: '.set-or-replace Services <| externaldata(x_ConsumedService: string, x_ResourceType: string, ServiceName: string, ServiceCategory: string, ServiceSubcategory: string, PublisherName: string, x_PublisherCategory: string, x_Environment: string, x_ServiceModel: string)[@"${ftkReleaseUri}/Services.csv"] with (format="csv", ignoreFirstRecord=true)'
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Ingestion Complete
                    name: 'Ingestion Complete'
                    type: 'SetVariable'
                    dependsOn: [
                      {
                        activity: 'Update Services in ADX'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      variableName: 'tryAgain'
                      value: false
                    }
                  }
                ]
              }
            }
            { // Abort On Error
              name: 'Abort On Error'
              type: 'SetVariable'
              dependsOn: [
                {
                  activity: 'If Has Capacity'
                  dependencyConditions: [
                    'Failed'
                  ]
                }
              ]
              policy: {
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                variableName: 'tryAgain'
                value: false
              }
            }
          ]
          timeout: '0.02:00:00'
        }
      }
      { // Timeout Error
        name: 'Timeout Error'
        type: 'Fail'
        dependsOn: [
          {
            activity: 'Until Capacity Is Available'
            dependencyConditions: [
              'Failed'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          message: 'Data Explorer ingestion timed out after 2 hours while waiting for available capacity. Please re-run this pipeline to re-attempt ingestion. If you continue to see this error, please report an issue at https://aka.ms/ftk/ideas.'
          errorCode: 'DataExplorerIngestionTimeout'
        }
      }
    ]
    concurrency: 1
    variables: {
      version: {
        type: 'String'
      }
      scopes: {
        type: 'String'
      }
      retention: {
        type: 'String'
      }
      tryAgain: {
        type: 'Boolean'
        defaultValue: true
      }
    }
  }
}

//------------------------------------------------------------------------------
// ingestion_ETL_dataExplorer pipeline
// Triggered by ingestion_ExecuteETL
//------------------------------------------------------------------------------
@description('Ingests parquet data into an Azure Data Explorer cluster.')
resource pipeline_ToDataExplorer 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = if (useAzure || useFabric) {
  name: '${core.containers.ingestion}_ETL_dataExplorer'
  parent: dataFactory
  properties: {
    activities: [
      { // Read Hub Config
        name: 'Read Hub Config'
        description: 'Read the hub config to determine how long data should be retained.'
        type: 'Lookup'
        policy: {
          timeout: '0.12:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'JsonSource'
            storeSettings: {
              type: 'AzureBlobFSReadSettings'
              recursive: false
              enablePartitionDiscovery: false
            }
            formatSettings: {
              type: 'JsonReadSettings'
            }
          }
          dataset: {
            referenceName: core.datasets.config
            type: 'DatasetReference'
            parameters: {
              fileName: core.settings.file
              folderPath: core.containers.config
            }
          }
        }
      }
      { // Set Final Retention Months
        name: 'Set Final Retention Months'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Read Hub Config'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'finalRetentionMonths'
          value: {
            value: '@coalesce(activity(\'Read Hub Config\').output.firstRow.retention.final.months, 999)'
            type: 'Expression'
          }
        }
      }
      { // Until Capacity Is Available
        name: 'Until Capacity Is Available'
        type: 'Until'
        dependsOn: [
          {
            activity: 'Set Final Retention Months'
            dependencyConditions: [
              'Completed'
              'Skipped'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@equals(variables(\'tryAgain\'), false)'
            type: 'Expression'
          }
          activities: [
            { // Confirm Ingestion Capacity
              name: 'Confirm Ingestion Capacity'
              type: 'AzureDataExplorerCommand'
              dependsOn: []
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                command: '.show capacity | where Resource == \'Ingestions\' | project Remaining'
                commandTimeout: '00:20:00'
              }
              linkedServiceName: {
                referenceName: linkedService_dataExplorer.name
                type: 'LinkedServiceReference'
              }
            }
            { // If Has Capacity
              name: 'If Has Capacity'
              type: 'IfCondition'
              dependsOn: [
                {
                  activity: 'Confirm Ingestion Capacity'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              userProperties: []
              typeProperties: {
                expression: {
                  value: '@or(equals(activity(\'Confirm Ingestion Capacity\').output.count, 0), greater(activity(\'Confirm Ingestion Capacity\').output.value[0].Remaining, 0))'
                  type: 'Expression'
                }
                ifFalseActivities: [
                  { // Wait for Ingestion
                    name: 'Wait for Ingestion'
                    type: 'Wait'
                    dependsOn: []
                    userProperties: []
                    typeProperties: {
                      waitTimeInSeconds: 15
                    }
                  }
                  { // Try Again
                    name: 'Try Again'
                    type: 'SetVariable'
                    dependsOn: [
                      {
                        activity: 'Wait for Ingestion'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      variableName: 'tryAgain'
                      value: true
                    }
                  }
                ]
                ifTrueActivities: [
                  { // Pre-Ingest Cleanup
                    name: 'Pre-Ingest Cleanup'
                    description: 'Cost Management exports include all month-to-date data from the previous export run. To ensure data is not double-reported, it must be dropped from the raw table before ingestion completes. Remove previous ingestions into the raw table for the month and any previous runs of the current ingestion month file in any table.'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: []
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    typeProperties: {
                      command: {
                        value: '@concat(\'.drop extents <| .show extents | where (TableName == "\', pipeline().parameters.table, \'" and Tags !has "drop-by:\', pipeline().parameters.ingestionId, \'" and Tags has "drop-by:\', pipeline().parameters.folderPath, \'") or (Tags has "drop-by:\', pipeline().parameters.ingestionId, \'" and Tags has "drop-by:\', pipeline().parameters.folderPath, \'/\', pipeline().parameters.originalFileName, \'")\')'
                        type: 'Expression'
                      }
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Ingest Data
                    name: 'Ingest Data'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: [
                      {
                        activity: 'Pre-Ingest Cleanup'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 3
                      retryIntervalInSeconds: 120
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      command: {
                        // cSpell:ignore abfss, toscalar
                        value: '@concat(\'.ingest into table \', pipeline().parameters.table, \' ("abfss://${core.containers.ingestion}@${app.storage}.dfs.${environment().suffixes.storage}/\', pipeline().parameters.folderPath, \'/\', pipeline().parameters.fileName, \';${useFabric ? 'impersonate' : 'managed_identity=system'}") with (format="parquet", ingestionMappingReference="\', pipeline().parameters.table, \'_mapping", tags="[\\"drop-by:\', pipeline().parameters.ingestionId, \'\\", \\"drop-by:\', pipeline().parameters.folderPath, \'/\', pipeline().parameters.originalFileName, \'\\", \\"drop-by:ftk-version-${finOpsToolkitVersion}\\"]"); print Success = assert(iff(toscalar($command_results | project-keep HasErrors) == false, true, false), "Ingestion Failed")\')'
                        type: 'Expression'
                      }
                      commandTimeout: '01:00:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Post-Ingest Cleanup
                    name: 'Post-Ingest Cleanup'
                    description: 'Cost Management exports include all month-to-date data from the previous export run. To ensure data is not double-reported, it must be dropped after ingestion completes. Remove the current ingestion month file from raw and any old ingestions for the month from the final table.'
                    type: 'AzureDataExplorerCommand'
                    dependsOn: [
                      {
                        activity: 'Ingest Data'
                        dependencyConditions: [
                          'Completed'
                        ]
                      }
                    ]
                    policy: {
                      timeout: '0.12:00:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    typeProperties: {
                      command: {
                        // cSpell:ignore startofmonth, strcat, todatetime
                        value: '@concat(\'.drop extents <| .show extents | extend isOldFinalData = (TableName startswith "\', replace(pipeline().parameters.table, \'_raw\', \'_final_v\'), \'" and Tags !has "drop-by:\', pipeline().parameters.ingestionId, \'" and Tags has "drop-by:\', pipeline().parameters.folderPath, \'") | extend isPastFinalRetention = (TableName startswith "\', replace(pipeline().parameters.table, \'_raw\', \'_final_v\'), \'" and todatetime(substring(strcat(replace_string(extract("drop-by:[A-Za-z]+/(\\\\d{4}/\\\\d{2}(/\\\\d{2})?)", 1, Tags), "/", "-"), "-01"), 0, 10)) < datetime_add("month", -\', if(lessOrEquals(variables(\'finalRetentionMonths\'), 0), 0, variables(\'finalRetentionMonths\')), \', startofmonth(now()))) | where isOldFinalData or isPastFinalRetention\')'
                        type: 'Expression'
                      }
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: INGESTION_DB  // Do not use dynamic reference since that won't work with Fabric
                      }
                    }
                  }
                  { // Ingestion Complete
                    name: 'Ingestion Complete'
                    type: 'SetVariable'
                    dependsOn: [
                      {
                        activity: 'Post-Ingest Cleanup'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    policy: {
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      variableName: 'tryAgain'
                      value: false
                    }
                  }
                  { // Abort On Ingestion Error
                    name: 'Abort On Ingestion Error'
                    type: 'SetVariable'
                    dependsOn: [
                      {
                        activity: 'Ingest Data'
                        dependencyConditions: [
                          'Failed'
                        ]
                      }
                    ]
                    policy: {
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      variableName: 'tryAgain'
                      value: false
                    }
                  }
                  { // Error: DataExplorerIngestionFailed
                    name: 'Ingestion Failed Error'
                    type: 'Fail'
                    dependsOn: [
                      {
                        activity: 'Abort On Ingestion Error'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    userProperties: []
                    typeProperties: {
                      message: {
                        value: '@concat(\'Data Explorer ingestion into the \', pipeline().parameters.table, \' table failed. Please fix the error and rerun ingestion for the following folder path: "\', pipeline().parameters.folderPath, \'". File: \', pipeline().parameters.originalFileName, \'. Error: \', if(greater(length(activity(\'Ingest Data\').output.errors), 0), activity(\'Ingest Data\').output.errors[0].Message, \'Unknown\'), \' (Code: \', if(greater(length(activity(\'Ingest Data\').output.errors), 0), activity(\'Ingest Data\').output.errors[0].Code, \'None\'), \')\')'
                        type: 'Expression'
                      }
                      errorCode: 'DataExplorerIngestionFailed'
                    }
                  }
                  { // Abort On Pre-Ingest Drop Error
                    name: 'Abort On Pre-Ingest Drop Error'
                    type: 'SetVariable'
                    dependsOn: [
                      {
                        activity: 'Pre-Ingest Cleanup'
                        dependencyConditions: [
                          'Failed'
                        ]
                      }
                    ]
                    policy: {
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      variableName: 'tryAgain'
                      value: false
                    }
                  }
                  { // Error: DataExplorerPreIngestionDropFailed
                    name: 'Pre-Ingest Drop Failed Error'
                    type: 'Fail'
                    dependsOn: [
                      {
                        activity: 'Abort On Pre-Ingest Drop Error'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    userProperties: []
                    typeProperties: {
                      message: {
                        value: '@concat(\'Data Explorer pre-ingestion cleanup (drop extents from raw table) for the \', pipeline().parameters.table, \' table failed. Ingestion was not completed. Please fix the error and rerun ingestion for the following folder path: "\', pipeline().parameters.folderPath, \'". File: \', pipeline().parameters.originalFileName, \'. Error: \', if(greater(length(activity(\'Pre-Ingest Cleanup\').output.errors), 0), activity(\'Pre-Ingest Cleanup\').output.errors[0].Message, \'Unknown\'), \' (Code: \', if(greater(length(activity(\'Pre-Ingest Cleanup\').output.errors), 0), activity(\'Pre-Ingest Cleanup\').output.errors[0].Code, \'None\'), \')\')'
                        type: 'Expression'
                      }
                      errorCode: 'DataExplorerPreIngestionDropFailed'
                    }
                  }
                  { // Abort On Post-Ingest Drop Error
                    name: 'Abort On Post-Ingest Drop Error'
                    type: 'SetVariable'
                    dependsOn: [
                      {
                        activity: 'Post-Ingest Cleanup'
                        dependencyConditions: [
                          'Failed'
                        ]
                      }
                    ]
                    policy: {
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      variableName: 'tryAgain'
                      value: false
                    }
                  }
                  { // Error: DataExplorerPostIngestionDropFailed
                    name: 'Post-Ingest Drop Failed Error'
                    type: 'Fail'
                    dependsOn: [
                      {
                        activity: 'Abort On Post-Ingest Drop Error'
                        dependencyConditions: [
                          'Succeeded'
                        ]
                      }
                    ]
                    userProperties: []
                    typeProperties: {
                      message: {
                        value: '@concat(\'Data Explorer post-ingestion cleanup (drop extents from final tables) for the \', replace(pipeline().parameters.table, \'_raw\', \'_final_*\'), \' table failed. Please fix the error and rerun ingestion for the following folder path: "\', pipeline().parameters.folderPath, \'". File: \', pipeline().parameters.originalFileName, \'. Error: \', if(greater(length(activity(\'Post-Ingest Cleanup\').output.errors), 0), activity(\'Post-Ingest Cleanup\').output.errors[0].Message, \'Unknown\'), \' (Code: \', if(greater(length(activity(\'Post-Ingest Cleanup\').output.errors), 0), activity(\'Post-Ingest Cleanup\').output.errors[0].Code, \'None\'), \')\')'
                        type: 'Expression'
                      }
                      errorCode: 'DataExplorerPostIngestionDropFailed'
                    }
                  }
                ]
              }
            }
          ]
          timeout: '0.02:00:00'
        }
      }
    ]
    parameters: {
      folderPath: {
        type: 'string'
      }
      fileName: {
        type: 'string'
      }
      originalFileName: {
        type: 'string'
      }
      ingestionId: {
        type: 'string'
      }
      table: {
        type: 'string'
      }
    }
    variables: {
      tryAgain: {
        type: 'Boolean'
        defaultValue: true
      }
      logRetentionDays: {
        type: 'Integer'
        defaultValue: 0
      }
      finalRetentionMonths: {
        type: 'Integer'
        defaultValue: 999
      }
    }
    annotations: []
  }
}

//------------------------------------------------------------------------------
// ingestion_ExecuteETL pipeline
// Triggered by ingestion_ManifestAdded trigger
//------------------------------------------------------------------------------
@description('Queues the ingestion_ETL_dataExplorer pipeline to account for Data Factory pipeline trigger limits.')
resource pipeline_ExecuteIngestionETL 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = if (useAzure || useFabric) {
  name: '${core.containers.ingestion}_ExecuteETL'
  parent: dataFactory
  properties: {
    concurrency: 1
    activities: [
      { // Wait
        name: 'Wait'
        description: 'Files may not be available immediately after being created.'
        type: 'Wait'
        dependsOn: []
        userProperties: []
        typeProperties: {
          waitTimeInSeconds: 60
        }
      }
      { // Set Container Folder Path
        name: 'Set Container Folder Path'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Wait'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'containerFolderPath'
          value: {
            value: '@join(skip(array(split(pipeline().parameters.folderPath, \'/\')), 1), \'/\')'
            type: 'Expression'
          }
        }
      }
      { // Get Existing Parquet Files
        name: 'Get Existing Parquet Files'
        description: 'Get the previously ingested files so we can get file paths.'
        type: 'GetMetadata'
        dependsOn: [
          {
            activity: 'Set Container Folder Path'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        policy: {
          timeout: '0.12:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          dataset: {
            referenceName: core.datasets.ingestionFiles
            type: 'DatasetReference'
            parameters: {
              folderPath: '@variables(\'containerFolderPath\')'
            }
          }
          fieldList: [
            'exists'
            'childItems'
          ]
          storeSettings: {
            type: 'AzureBlobFSReadSettings'
            enablePartitionDiscovery: false
          }
          formatSettings: {
            type: 'ParquetReadSettings'
          }
        }
      }
      { // Filter Out Folders and manifest files
        name: 'Filter Out Folders'
        description: 'Remove any folders or manifest files.'
        type: 'Filter'
        dependsOn: [
          {
            activity: 'Get Existing Parquet Files'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@if(and(activity(\'Get Existing Parquet Files\').output.exists, contains(activity(\'Get Existing Parquet Files\').output, \'childItems\')), activity(\'Get Existing Parquet Files\').output.childItems, json(\'[]\'))'
            type: 'Expression'
          }
          condition: {
            value: '@and(equals(item().type, \'File\'), not(contains(toLower(item().name), \'manifest.json\')))'
            type: 'Expression'
          }
        }
      }
      { // Set Ingestion Timestamp
        name: 'Set Ingestion Timestamp'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Wait'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'timestamp'
          value: {
            value: '@utcNow()'
            type: 'Expression'
          }
        }
      }
      { // For Each Old File
        name: 'For Each Old File'
        description: 'Loop thru each of the existing files.'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Filter Out Folders'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Ingestion Timestamp'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          batchCount: dataExplorerIngestionCapacity // Concurrency limit
          items: {
            value: '@activity(\'Filter Out Folders\').output.Value'
            type: 'Expression'
          }
          activities: [
            { // Execute
              name: 'Execute'
              description: 'Run the ADX ETL pipeline.'
              type: 'ExecutePipeline'
              dependsOn: []
              policy: {
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                pipeline: {
                  referenceName: pipeline_ToDataExplorer.name
                  type: 'PipelineReference'
                }
                waitOnCompletion: true
                parameters: {
                  folderPath: {
                    value: '@variables(\'containerFolderPath\')'
                    type: 'Expression'
                  }
                  fileName: {
                    value: '@item().name'
                    type: 'Expression'
                  }
                  originalFileName: {
                    value: '@last(array(split(item().name, \'${core.ingestionIdFileNameSeparator}\')))'
                    type: 'Expression'
                  }
                  ingestionId: {
                    value: '@concat(first(array(split(item().name, \'${core.ingestionIdFileNameSeparator}\'))), \'_\', variables(\'timestamp\'))'
                    type: 'Expression'
                  }
                  table: {
                    value: '@concat(first(array(split(variables(\'containerFolderPath\'), \'/\'))), \'_raw\')'
                    type: 'Expression'
                  }
                }
              }
            }
          ]
        }
      }
      { // If No Files
        name: 'If No Files'
        description: 'If there are no files found, fail the pipeline.'
        type: 'IfCondition'
        dependsOn: [
          {
            activity: 'Filter Out Folders'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@equals(length(activity(\'Filter Out Folders\').output.Value), 0)'
            type: 'Expression'
          }
          ifTrueActivities: [
            { // Error: IngestionFilesNotFound
              name: 'Files Not Found'
              type: 'Fail'
              dependsOn: []
              userProperties: []
              typeProperties: {
                message: {
                  value: '@concat(\'Unable to locate parquet files to ingest from the \', pipeline().parameters.folderPath, \' path. Please confirm the folder path is the full path, including the "ingestion" container and not starting with or ending with a slash ("/").\')'
                  type: 'Expression'
                }
                errorCode: 'IngestionFilesNotFound'
              }
            }
          ]
        }
      }
    ]
    parameters: {
      folderPath: {
        type: 'string'
      }
    }
    variables: {
      containerFolderPath: {
        type: 'string'
      }
      timestamp: {
        type: 'string'
      }
    }
    annotations: [
      'New ingestion'
    ]
  }
}

// Run initialization pipeline after everything is deployed
module runInitializationPipeline '../../fx/hub-initialize.bicep' = if (useAzure || useFabric) {
  name: 'Microsoft.FinOpsHubs.Analytics_InitializeHub'
  dependsOn: [
    ingestion_InitScripts
    ingestion_OpenDataInternalScripts
    ingestion_VersionedScripts
  ]
  params: {
    app: app
    dataFactoryInstances: [
      app.dataFactory
    ]
    identityName: appRegistration.outputs.triggerManagerIdentityName
    startPipelines: [
      pipeline_InitializeHub.name
    ]
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('Max ingestion capacity of the cluster.')
output clusterIngestionCapacity int = dataExplorerIngestionCapacity

@description('Metadata describing resources created by the Analytics app.')
output metadata AnalyticsMetadata = {
  id: 'Microsoft.FinOpsHubs.Analytics'
  version: finOpsToolkitVersion
  cluster: {
    #disable-next-line BCP318 // Null safety warning for conditional resource access
    id: useFabric ? '' : cluster.id
    #disable-next-line BCP318 // Null safety warning for conditional resource access
    name: useFabric ? '' : cluster.name
    uri: dataExplorerUri
    #disable-next-line BCP318 // Null safety warning for conditional resource access
    principalId: useFabric ? '' : cluster.identity.principalId
  }
  databases: {
    // Don't use cluster DB references since they won't work for Fabric
    ingestion: INGESTION_DB
    hub: HUB_DB
  }
  linkedServices: {
    hubDataExplorer: linkedService_dataExplorer.name
    ftkRepo: linkedService_ftkRepo.name
  }
  datasets: {
    hubDataExplorer: dataset_dataExplorer.name
    ftkReleaseFile: dataset_ftkReleaseFile.name
  }
}
