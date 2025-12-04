// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { getHubTags, getPublisherTags, HubCoreConfig, newHubCoreConfig } from 'hub-types.bicep'


//==============================================================================
// Parameters
//==============================================================================

@description('Optional. Name of the hub. Used to ensure unique resource names. Default: "finops-hub".')
param hubName string

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).')
param location string = resourceGroup().location

// @description('Optional. Azure location to use for a temporary Event Grid namespace to register the Microsoft.EventGrid resource provider if the primary location is not supported. The namespace will be deleted and is not used for hub operation. Default: "" (same as location).')
// param eventGridLocation string = ''

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Optional. Storage SKU to use. LRS = Lowest cost, ZRS = High availability. Note Standard SKUs are not available for Data Lake gen2 storage. Allowed: Premium_LRS, Premium_ZRS. Default: Premium_LRS.')
param storageSku string = 'Premium_LRS'

@description('Optional. Enable infrastructure encryption on the storage account. Default = false.')
param enableInfrastructureEncryption bool = false

@description('Optional. Remote storage account for ingestion dataset.')
param remoteHubStorageUri string = ''

@description('Optional. Storage account key for remote storage account.')
@secure()
param remoteHubStorageKey string = ''

// cSpell:ignore eventhouse
@description('Optional. Microsoft Fabric eventhouse query URI. Default: "" (do not use).')
param fabricQueryUri string = ''

@description('Optional. Number of capacity units for the Microsoft Fabric capacity. This is the number in your Fabric SKU (e.g., Trial = 1, F2 = 2, F64 = 64). This is used to manage parallelization in data pipelines. If you change capacity, please redeploy the template. Allowed values: 1 for the Fabric trial and 2-2048 based on the assigned Fabric capacity (e.g., F2-F2048). Default: 2.')
@minValue(1)
@maxValue(2048)
param fabricCapacityUnits int = 2

@description('Optional. Name of the Azure Data Explorer cluster to use for advanced analytics. If empty, Azure Data Explorer will not be deployed. Required to use with Power BI if you have more than $2-5M/mo in costs being monitored. Default: "" (do not use).')
param dataExplorerName string = ''

// https://learn.microsoft.com/azure/templates/microsoft.kusto/clusters?pivots=deployment-language-bicep#azuresku
@description('Optional. Name of the Azure Data Explorer SKU. Ignore when using Microsoft Fabric or not deploying Data Explorer. Default: "Dev(No SLA)_Standard_D11_v2".')
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
param dataExplorerSku string = 'Dev(No SLA)_Standard_D11_v2'

@description('Optional. Number of nodes to use in the cluster. This is used to manage parallelization in data pipelines. If you change Fabric SKU, please redeploy the template. Allowed values: 1 for the Basic SKU tier and 2-1000 for Standard. Default: 1 for dev/test SKUs, 2 for standard SKUs.')
@minValue(1)
@maxValue(1000)
param dataExplorerCapacity int = 1

// @description('Optional. Array of external tenant IDs that should have access to the cluster. Default: empty (no external access).')
// param dataExplorerTrustedExternalTenants string[] = []

@description('Optional. Tags to apply to all resources. We will also add the cm-resource-parent tag for improved cost roll-ups in Cost Management.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Optional. List of scope IDs to monitor and ingest cost for.')
param scopesToMonitor array = []

@description('Optional. Number of days of data to retain in the msexports container. Default: 0.')
param exportRetentionInDays int = 0

@description('Optional. Number of months of data to retain in the ingestion container. Default: 13.')
param ingestionRetentionInMonths int = 13

@description('Optional. Number of days of data to retain in the Data Explorer *_raw tables. Default: 0.')
param dataExplorerRawRetentionInDays int = 0

@description('Optional. Number of months of data to retain in the Data Explorer *_final_v* tables. Default: 13.')
param dataExplorerFinalRetentionInMonths int = 13

@description('Optional. Enable public access to the data lake. Default: true.')
param enablePublicAccess bool = true

@description('Optional. Address space for the workload. A /26 is required for the workload. Default: "10.20.30.0/26".')
param virtualNetworkAddressPrefix string = '10.20.30.0/26'

@description('Optional. Enable telemetry to track anonymous module usage trends, monitor for bugs, and improve future releases.')
param enableDefaultTelemetry bool = true


//==============================================================================
// Variables
//==============================================================================

// TODO: Move hub config to be retrieved from the cloud

// Hub details
var coreConfig = newHubCoreConfig(
  hubName,
  location,
  tags,
  tagsByResource,
  storageSku,
  enableInfrastructureEncryption,
  enablePublicAccess,
  virtualNetworkAddressPrefix
)

// Generate globally unique Data Factory name: 3-63 chars; letters, numbers, non-repeating dashes
var dataFactoryPrefix = '${replace(hubName, '_', '-')}-engine'
var dataFactorySuffix = '-${coreConfig.hub.suffix}'
var dataFactoryName = replace(
  '${take(dataFactoryPrefix, 63 - length(dataFactorySuffix))}${dataFactorySuffix}',
  '--',
  '-'
)


// Do not reference these deployments directly or indirectly to avoid a DeploymentNotFound error
var useFabric = !empty(fabricQueryUri)
var deployDataExplorer = !useFabric && !empty(dataExplorerName)
var safeDataExplorerName = !deployDataExplorer ? '' : dataExplorer.outputs.clusterName
var safeDataExplorerUri = useFabric ? fabricQueryUri : (!deployDataExplorer ? '' : dataExplorer.outputs.clusterUri)
var safeDataExplorerId = !deployDataExplorer ? '' : dataExplorer.outputs.clusterId
var safeDataExplorerIngestionDb = useFabric ? 'Ingestion' : (!deployDataExplorer ? '' : dataExplorer.outputs.ingestionDbName)
var safeDataExplorerIngestionCapacity = useFabric ? fabricCapacityUnits : (!deployDataExplorer ? 1 : dataExplorer.outputs.clusterIngestionCapacity)
var safeDataExplorerPrincipalId = !deployDataExplorer ? '' : dataExplorer.outputs.principalId
var safeVnetId = enablePublicAccess ? '' : vnet.outputs.vNetId
var safeDataExplorerSubnetId = enablePublicAccess ? '' : vnet.outputs.dataExplorerSubnetId
var safeFinopsHubSubnetId = enablePublicAccess ? '' : vnet.outputs.finopsHubSubnetId
// var safeScriptSubnetId = enablePublicAccess ? '' : vnet.outputs.scriptSubnetId

// cSpell:ignore eventgrid
// var eventGridName = 'finops-hub-eventgrid-${config.hub.suffix}'

// var eventGridPrefix = '${replace(hubName, '_', '-')}-ns'
// var eventGridSuffix = '-${config.hub.suffix}'
// var eventGridName = replace(
//   '${take(eventGridPrefix, 50 - length(eventGridSuffix))}${eventGridSuffix}',
//   '--',
//   '-'
// )

// EventGrid Contributor role
// var eventGridContributorRoleId = '1e241071-0855-49ea-94dc-649edcd759de'

// cSpell:ignore israelcentral, uaenorth, italynorth, switzerlandnorth, mexicocentral, southcentralus, polandcentral, swedencentral, spaincentral, francecentral, usdodeast, usdodcentral
// Find a fallback region for EventGrid
// var eventGridLocationFallback = {
//   israelcentral: 'uaenorth'
//   italynorth: 'switzerlandnorth'
//   mexicocentral: 'southcentralus'
//   polandcentral: 'swedencentral'
//   spaincentral: 'francecentral'
//   usdodeast: 'usdodcentral'
// }
// var finalEventGridLocation = eventGridLocation != null && !empty(eventGridLocation) ? eventGridLocation : (eventGridLocationFallback[?location] ?? location)

// The last segment of the GUID in the telemetryId (40b) is used to identify this module
// Remaining characters identify settings; must be <= 12 chars -- Example: (guid)_RLXD##x1000P
var telemetryId = '00f120b5-2007-6120-0000-40b000000000'
var telemetryString = join([
  // R = remote hubs enabled
  empty(remoteHubStorageUri) || empty(remoteHubStorageKey) ? '' : 'R'
  // L = LRS, Z = ZRS
  substring(split(storageSku, '_')[1], 0, 1)
  // F = Fabric enabled
  !useFabric ? '' : 'F${fabricCapacityUnits}'
  // X = ADX enabled + D (dev) or S (standard) SKU
  !deployDataExplorer ? '' : 'X${substring(dataExplorerSku, 0, 1)}'
  // Number of cores in the VM size
  !deployDataExplorer ? '' : replace(replace(replace(replace(replace(replace(replace(replace(split(split(dataExplorerSku, 'Standard_')[1], '_')[0], 'C', ''), 'D', ''), 'E', ''), 'L', ''), 'a', ''), 'd', ''), 'i', ''), 's', '')
  // Number of nodes in the cluster
  !deployDataExplorer || dataExplorerCapacity == 1 ? '' : 'x${dataExplorerCapacity}'
  // P = private endpoints enabled
  enablePublicAccess ? '' : 'P'
], '')


//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Base resources needed for hub apps
//------------------------------------------------------------------------------

module coreNetwork 'core-network.bicep' = {
  name: 'Microsoft.FinOpsToolkit.Hubs.Core_Network'
  params: {
    coreConfig: coreConfig
  }
}

//------------------------------------------------------------------------------
// App registration
//------------------------------------------------------------------------------

module appRegistration 'hub-app.bicep' = {
  name: 'pid-${telemetryId}_${telemetryString}_${uniqueString(deployment().name, location)}'
  params: {
    // hubName: hubName
    publisher: 'Microsoft FinOps hubs'
    namespace: 'Microsoft.FinOpsHubs'
    appName: 'Core'
    displayName: 'FinOps hub core'
    appVersion: loadTextContent('ftkver.txt') // cSpell:ignore ftkver
    features: [
      'Storage'
    ]
    telemetryString: telemetryString
    enableDefaultTelemetry: enableDefaultTelemetry

    coreConfig: coreConfig
  }
}

//------------------------------------------------------------------------------
// Virtual network
//------------------------------------------------------------------------------

// cSpell:ignore vnet
// TODO: Move to core-network.bicep
module vnet 'vnet.bicep' = if (!enablePublicAccess) {
  name: 'vnet'
  params: {
    hubName: hubName
    location: location
    virtualNetworkAddressPrefix: coreConfig.network.addressPrefix
    tags: coreConfig.hub.tags
    tagsByResource: tagsByResource
  }
}

//------------------------------------------------------------------------------
// ADLSv2 storage account for staging and archive
//------------------------------------------------------------------------------

module storage 'storage.bicep' = {
  name: 'storage'
  dependsOn: [
    coreNetwork
    vnet
  ]
  params: {
    storageAccountName: appRegistration.outputs.config.publisher.storage
    location: location
    tags: coreConfig.hub.tags
    tagsByResource: tagsByResource
    scopesToMonitor: scopesToMonitor
    msexportRetentionInDays: exportRetentionInDays  // cSpell:ignore msexport
    ingestionRetentionInMonths: ingestionRetentionInMonths
    rawRetentionInDays: dataExplorerRawRetentionInDays
    finalRetentionInMonths: dataExplorerFinalRetentionInMonths
    scriptSubnetId: coreConfig.network.subnets.scripts
    scriptStorageAccountName: coreConfig.deployment.storage
    enablePublicAccess: enablePublicAccess
  }
}

//------------------------------------------------------------------------------
// Data Explorer for analytics
//------------------------------------------------------------------------------

module dataExplorer 'dataExplorer.bicep' = if (deployDataExplorer) {
  name: 'dataExplorer'
  params: {
    clusterName: dataExplorerName
    clusterSku: dataExplorerSku
    clusterCapacity: dataExplorerCapacity
    // TODO: Figure out why this is breaking upgrades -- clusterTrustedExternalTenants: dataExplorerTrustedExternalTenants
    location: location
    tags: coreConfig.hub.tags
    tagsByResource: tagsByResource
    dataFactoryName: dataFactory.name
    rawRetentionInDays: dataExplorerRawRetentionInDays
    virtualNetworkId: safeVnetId
    privateEndpointSubnetId: safeDataExplorerSubnetId
    enablePublicAccess: enablePublicAccess
    storageAccountName: storage.outputs.name
  }
}

//------------------------------------------------------------------------------
// Data Factory and pipelines
//------------------------------------------------------------------------------

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  // TODO: Switch to use publisher tags
  tags: getHubTags(coreConfig, 'Microsoft.DataFactory/factories')
  identity: { type: 'SystemAssigned' }
  properties: any({ // Using any() to hide the error that gets surfaced because globalConfigurations is not in the ADF schema yet
      globalConfigurations: {
        PipelineBillingEnabled: 'true'
      }
  })
}

module dataFactoryResources 'dataFactory.bicep' = {
  name: 'dataFactoryResources'
  params: {
    hubName: hubName
    dataFactoryName: dataFactory.name
    location: location
    tags: appRegistration.outputs.config.publisher.tags
    tagsByResource: tagsByResource
    storageAccountName: storage.outputs.name
    exportContainerName: storage.outputs.exportContainer
    configContainerName: storage.outputs.configContainer
    ingestionContainerName: storage.outputs.ingestionContainer
    dataExplorerName: safeDataExplorerName
    dataExplorerPrincipalId: safeDataExplorerPrincipalId
    dataExplorerIngestionDatabase: safeDataExplorerIngestionDb
    dataExplorerIngestionCapacity: safeDataExplorerIngestionCapacity
    dataExplorerUri: safeDataExplorerUri
    dataExplorerId: safeDataExplorerId
    keyVaultName: empty(remoteHubStorageKey) ? '' : keyVault.outputs.name
    remoteHubStorageUri: remoteHubStorageUri
    enablePublicAccess: enablePublicAccess
  }
}

//------------------------------------------------------------------------------
// Key Vault for storing secrets
//------------------------------------------------------------------------------

module keyVault 'keyVault.bicep' = if (!empty(remoteHubStorageKey)) {
  name: 'keyVault'
  params: {
    hubName: hubName
    uniqueSuffix: coreConfig.hub.suffix
    location: location
    tags: appRegistration.outputs.config.app.tags
    tagsByResource: tagsByResource
    storageAccountKey: remoteHubStorageKey
    enablePublicAccess: enablePublicAccess
    virtualNetworkId: safeVnetId
    privateEndpointSubnetId: safeFinopsHubSubnetId
    accessPolicies: [
      {
        objectId: dataFactory.identity.principalId
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

//==============================================================================
// Outputs
//==============================================================================

@description('Name of the deployed hub instance.')
output name string = hubName

@description('Azure resource location resources were deployed to.')
output location string = location

@description('Name of the Data Factory.')
output dataFactoryName string = dataFactory.name

@description('Resource ID of the storage account created for the hub instance. This must be used when creating the Cost Management export.')
output storageAccountId string = storage.outputs.resourceId

@description('Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.')
output storageAccountName string = storage.outputs.name

@description('URL to use when connecting custom Power BI reports to your data.')
output storageUrlForPowerBI string = 'https://${storage.outputs.name}.dfs.${environment().suffixes.storage}/${storage.outputs.ingestionContainer}'

@description('The resource ID of the Data Explorer cluster.')
output clusterId string = !deployDataExplorer ? '' : dataExplorer.outputs.clusterId

@description('The URI of the Data Explorer cluster.')
output clusterUri string = useFabric ? fabricQueryUri : (!deployDataExplorer ? '' : dataExplorer.outputs.clusterUri)

@description('The name of the Data Explorer database used for ingesting data.')
output ingestionDbName string = useFabric ? 'Ingestion' : (!deployDataExplorer ? '' : dataExplorer.outputs.ingestionDbName)

@description('The name of the Data Explorer database used for querying data.')
output hubDbName string = useFabric ? 'Hub' : (!deployDataExplorer ? '' : dataExplorer.outputs.hubDbName)

@description('Object ID of the Data Factory managed identity. This will be needed when configuring managed exports.')
output managedIdentityId string = dataFactory.identity.principalId

@description('Azure AD tenant ID. This will be needed when configuring managed exports.')
output managedIdentityTenantId string = tenant().tenantId
