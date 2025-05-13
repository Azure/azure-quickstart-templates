//==============================================================================
// Parameters
//==============================================================================

// @description('Required. Name of the FinOps hub instance. Used to ensure unique resource names.')
// param hubName string

// @description('Required. Suffix to add to the storage account name to ensure uniqueness.')
// @minLength(6) // Min length requirement is to avoid a false positive warning
// param uniqueSuffix string

@description('Optional. Name of the Azure Data Explorer cluster to use for advanced analytics. If empty, Azure Data Explorer will not be deployed. Required to use with Power BI if you have more than $2-5M/mo in costs being monitored. Default: "" (do not use).')
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

@description('Optional. Forces the table to be updated if different from the last time it was deployed.')
param forceUpdateTag string = utcNow()

@description('Optional. If true, ingestion will continue even if some rows fail to ingest. Default: false.')
param continueOnErrors bool = false

@description('Optional. Azure location to use for the managed identity and deployment script to auto-start triggers. Default: (resource group location).')
param location string = resourceGroup().location

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Required. Name of the Data Factory instance.')
param dataFactoryName string

@description('Optional. Number of days of data to retain in the Data Explorer *_raw tables. Default: 0.')
param rawRetentionInDays int = 0

@description('Required. Name of the storage account to use for data ingestion.')
param storageAccountName string

@description('Required. Resource ID of the virtual network for private endpoints.')
param virtualNetworkId string

@description('Required. Resource ID of the subnet for private endpoints.')
param privateEndpointSubnetId string

@description('Optional. Enable public access.')
param enablePublicAccess bool

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

// cSpell:ignore ftkver, privatelink
var dataExplorerPrivateDnsZoneName = replace('privatelink.${location}.${replace(environment().suffixes.storage, 'core', 'kusto')}', '..', '.')

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

//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Dependencies
//------------------------------------------------------------------------------

// Get data factory instance
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
}

resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: 'privatelink.queue.${environment().suffixes.storage}'
}

resource tablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: 'privatelink.table.${environment().suffixes.storage}'
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

//------------------------------------------------------------------------------
// Cluster + databases
//------------------------------------------------------------------------------

//  Kusto cluster
resource cluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: clusterName
  location: location
  tags: union(tags, tagsByResource[?'Microsoft.Kusto/clusters'] ?? {})
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
    publicNetworkAccess: enablePublicAccess ? 'Enabled' : 'Disabled'
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
    name: 'Ingestion'
    location: location
    kind: 'ReadWrite'
  }

  resource hubDb 'databases' = {
    name: 'Hub'
    location: location
    kind: 'ReadWrite'
  }
}

module ingestion_OpenDataInternalScripts 'hub-database.bicep' = {
  name: 'ingestion_OpenDataInternalScripts'
  params: {
    clusterName: cluster.name
    databaseName: cluster::ingestionDb.name
    scripts: {
      OpenDataFunctions_resource_type_1: loadTextContent('scripts/OpenDataFunctions_resource_type_1.kql')
      OpenDataFunctions_resource_type_2: loadTextContent('scripts/OpenDataFunctions_resource_type_2.kql')
      OpenDataFunctions_resource_type_3: loadTextContent('scripts/OpenDataFunctions_resource_type_3.kql')
      OpenDataFunctions_resource_type_4: loadTextContent('scripts/OpenDataFunctions_resource_type_4.kql')
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module ingestion_CommonScripts 'hub-database.bicep' = {
  name: 'ingestion_CommonScripts'
  dependsOn: [
    ingestion_OpenDataInternalScripts
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::ingestionDb.name
    scripts: {
      openDataScript: loadTextContent('scripts/OpenDataFunctions.kql')
      commonScript: loadTextContent('scripts/Common.kql')
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module ingestion_SetupScript 'hub-database.bicep' = {
  name: 'ingestion_SetupScript'
  dependsOn: [
    ingestion_CommonScripts
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::ingestionDb.name
    scripts: {
      setupScript: replace(loadTextContent('scripts/IngestionSetup.kql'), '$$rawRetentionInDays$$', string(rawRetentionInDays))
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}

module hub_SetupScript 'hub-database.bicep' = {
  name: 'hub_SetupScript'
  dependsOn: [
    ingestion_SetupScript
  ]
  params: {
    clusterName: cluster.name
    databaseName: cluster::hubDb.name
    scripts: {
      commonScript: loadTextContent('scripts/Common.kql')
      setupScript: replace(loadTextContent('scripts/HubSetup.kql'), '$$rawRetentionInDays$$', string(rawRetentionInDays))
    }
    continueOnErrors: continueOnErrors
    forceUpdateTag: forceUpdateTag
  }
}
    
// Authorize Kusto Cluster to read storage
resource clusterStorageAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cluster.name, subscription().id, 'Storage Blob Data Contributor')
  scope: storage
  properties: {
    description: 'Give "Storage Blob Data Contributor" to the cluster'
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
resource dataExplorerPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = if (!enablePublicAccess) {
  name: dataExplorerPrivateDnsZoneName
  location: 'global'
  tags: union(tags, tagsByResource[?'Microsoft.Network/privateDnsZones'] ?? {})
  properties: {}
}

// Link DNS zone to VNet
resource dataExplorerPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (!enablePublicAccess) {
  name: '${replace(dataExplorerPrivateDnsZone.name, '.', '-')}-link'
  location: 'global'
  parent: dataExplorerPrivateDnsZone
  tags: union(tags, tagsByResource[?'Microsoft.Network/privateDnsZones/virtualNetworkLinks'] ?? {})
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

// Private endpoint
resource dataExplorerEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (!enablePublicAccess) {
  name: '${cluster.name}-ep'
  location: location
  tags: union(tags, tagsByResource[?'Microsoft.Network/privateEndpoints'] ?? {})
  properties: {
    subnet: {
      id: privateEndpointSubnetId
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
resource dataExplorerPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (!enablePublicAccess) {
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

//==============================================================================
// Outputs
//==============================================================================

@description('The resource ID of the cluster.')
output clusterId string = cluster.id

@description('The ID of the cluster system assigned managed identity.')
output principalId string = cluster.identity.principalId

@description('The name of the cluster.')
output clusterName string = cluster.name

@description('The URI of the cluster.')
output clusterUri string = cluster.properties.uri

@description('The name of the database for data ingestion.')
output ingestionDbName string = cluster::ingestionDb.name

@description('The name of the database for queries.')
output hubDbName string = cluster::hubDb.name

@description('Max ingestion capacity of the cluster.')
output clusterIngestionCapacity int = ingestionCapacity[?clusterSku] ?? 1
