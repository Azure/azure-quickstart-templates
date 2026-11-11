// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { getHubTags, newApp, newHub } from 'fx/hub-types.bicep'


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

@description('Optional. SKU to use for the KeyVault instance, if enabled. Allowed values: "standard", "premium". Default: "premium".')
@allowed([
  'premium'
  'standard'
])
param keyVaultSku string = 'premium'

@description('Optional. Enable purge protection for the Key Vault. Default: false.')
param enablePurgeProtection bool = false

@description('Optional. Remote storage account for ingestion dataset.')
param remoteHubStorageUri string = ''

@description('Optional. Storage account key for remote storage account.')
@secure()
param remoteHubStorageKey string = ''

@description('Optional. Enable managed exports where your FinOps hub instance will create and run Cost Management exports on your behalf. Not supported for Microsoft Customer Agreement (MCA) billing profiles. Requires the ability to grant the Role Based Access Control Administrator role to FinOps hubs, which is required to create Cost Management exports. Default: true.')
param enableManagedExports bool = true

@description('Optional. Enable recommendations ingested from Azure Resource Graph based on configurable queries. The Data Factory managed identity requires Reader role on management groups or subscriptions to execute Resource Graph queries. Default: false.')
param enableRecommendations bool = false

@description('Optional. Enable Azure Hybrid Benefit recommendations that flag VMs and SQL VMs without Azure Hybrid Benefit enabled. May generate noise if your organization does not have on-premises licenses. Requires enableRecommendations. Default: false.')
param enableAHBRecommendations bool = false

@description('Optional. Enable non-Spot AKS cluster recommendations that flag AKS clusters with autoscaling but not using Spot VMs. May generate noise since Spot VMs are only appropriate for interruptible workloads. Requires enableRecommendations. Default: false.')
param enableSpotRecommendations bool = false

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
  'Standard_E2a_v4'             // 2 CPU, 14GB RAM, 78GB cache, $220/mo
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

@description('Optional. Number of days of data to retain in the msexports container. If not specified, keeps the current value from settings.json (0 for new hubs).')
param exportRetentionInDays int?

@description('Optional. Number of months of data to retain in the ingestion container. If not specified, keeps the current value from settings.json (13 for new hubs).')
param ingestionRetentionInMonths int?

@description('Optional. Number of days of data to retain in the Data Explorer *_raw tables. If not specified, keeps the current value from settings.json (0 for new hubs).')
param dataExplorerRawRetentionInDays int?

@description('Optional. Number of months of data to retain in the Data Explorer *_final_v* tables. If not specified, keeps the current value from settings.json (13 for new hubs).')
param dataExplorerFinalRetentionInMonths int?

@description('Optional. Enable public access to the data lake. Default: true.')
param enablePublicAccess bool = true

@description('Optional. Deploy a NAT Gateway for controlled outbound access when private routing is enabled. When true, the script and Data Explorer subnets route outbound traffic through the NAT Gateway. Ignored when enablePublicAccess is true. Default: false.')
param enableNatGateway bool = false

@description('Optional. Address space for the workload. Minimum /26 subnet size is required for the workload. Default: "10.20.30.0/26".')
param virtualNetworkAddressPrefix string = '10.20.30.0/26'

@description('Optional. Enable telemetry to track anonymous module usage trends, monitor for bugs, and improve future releases.')
param enableDefaultTelemetry bool = true


//==============================================================================
// Variables
//==============================================================================

// TODO: Move hub config to be retrieved from the cloud

// Hub details
var hub = newHub(
  hubName,
  location,
  tags,
  tagsByResource,
  storageSku,
  keyVaultSku,
  enablePurgeProtection,
  enableInfrastructureEncryption,
  enablePublicAccess,
  enableNatGateway,
  virtualNetworkAddressPrefix,
  enableDefaultTelemetry
)

var useFabric = !empty(fabricQueryUri)
var useAzureDataExplorer = !useFabric && !empty(dataExplorerName)  // Prefer Fabric over Azure Data Explorer

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
  !useAzureDataExplorer ? '' : 'X${substring(dataExplorerSku, 0, 1)}'
  // Number of cores in the VM size
  !useAzureDataExplorer ? '' : replace(replace(replace(replace(replace(replace(replace(replace(split(split(dataExplorerSku, 'Standard_')[1], '_')[0], 'C', ''), 'D', ''), 'E', ''), 'L', ''), 'a', ''), 'd', ''), 'i', ''), 's', '')
  // Number of nodes in the cluster
  !useAzureDataExplorer || dataExplorerCapacity == 1 ? '' : 'x${dataExplorerCapacity}'
  // P = private endpoints enabled
  enablePublicAccess ? '' : 'P'
], '')


//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Telemetry
//------------------------------------------------------------------------------

resource telemetry 'Microsoft.Resources/deployments@2022-09-01' = if (enableDefaultTelemetry) {
  name: 'pid-${telemetryId}_${telemetryString}_${uniqueString(deployment().name, location)}'
  tags: getHubTags(hub, 'Microsoft.Resources/deployments')
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      metadata: {
        _generator: {
          name: 'FinOps toolkit'
          version: loadTextContent('fx/ftkver.txt') // cSpell:ignore ftkver
        }
      }
      resources: []
    }
  }
}

//------------------------------------------------------------------------------
// Hub core app
//------------------------------------------------------------------------------

module core 'Microsoft.FinOpsHubs/Core/app.bicep' = {
  name: 'Microsoft.FinOpsHubs.Core'
  params: {
    app: newApp(hub, 'Microsoft.FinOpsHubs', 'Core')
    scopesToMonitor: scopesToMonitor
    msexportRetentionInDays: exportRetentionInDays  // cSpell:ignore msexport
    ingestionRetentionInMonths: ingestionRetentionInMonths
    rawRetentionInDays: dataExplorerRawRetentionInDays
    finalRetentionInMonths: dataExplorerFinalRetentionInMonths
  }
}

//------------------------------------------------------------------------------
// Cost Management
//------------------------------------------------------------------------------

module cmExports 'Microsoft.CostManagement/Exports/app.bicep' = {
  name: 'Microsoft.CostManagement.Exports'
  params: {
    app: newApp(hub, 'Microsoft.CostManagement', 'Exports')
    core: core.outputs.metadata
  }
}

module cmManagedExports 'Microsoft.CostManagement/ManagedExports/app.bicep' = if (enableManagedExports) {
  name: 'Microsoft.CostManagement.ManagedExports'
  params: {
    app: newApp(hub, 'Microsoft.CostManagement', 'ManagedExports')
    core: core.outputs.metadata
    exports: cmExports.outputs.metadata
  }
}

//------------------------------------------------------------------------------
// Data Explorer for analytics
//------------------------------------------------------------------------------

module analytics 'Microsoft.FinOpsHubs/Analytics/app.bicep' = if (useFabric || useAzureDataExplorer) {
  name: 'Microsoft.FinOpsHubs.Analytics'
  dependsOn: hub.options.privateRouting ? [
    // When private endpoints are enabled, we need to explicitly block on anything that uses deployment scripts to guarantee only one deployment script runs at a time
    cmExports
    deleteOldResources
  ] : []
  params: {
    app: newApp(hub, 'Microsoft.FinOpsHubs', 'Analytics')
    core: core.outputs.metadata
    fabricQueryUri: fabricQueryUri
    fabricCapacityUnits: fabricCapacityUnits
    clusterName: dataExplorerName
    clusterSku: dataExplorerSku
    clusterCapacity: dataExplorerCapacity
    // Use the effective value from settings.json so a redeploy that omits the parameter keeps the current raw retention
    rawRetentionInDays: core.outputs.rawRetentionInDays
    // TODO: Figure out why this is breaking upgrades -- clusterTrustedExternalTenants: dataExplorerTrustedExternalTenants
  }
}

//------------------------------------------------------------------------------
// Ingestion queries
//------------------------------------------------------------------------------

module ingestionQueries 'Microsoft.FinOpsHubs/IngestionQueries/app.bicep' = if (enableRecommendations) {
  name: 'Microsoft.FinOpsHubs.IngestionQueries'
  params: {
    app: newApp(hub, 'Microsoft.FinOpsHubs', 'IngestionQueries')
    core: core.outputs.metadata
  }
}

module azureResourceGraph 'Microsoft.FinOpsHubs/AzureResourceGraph/app.bicep' = if (enableRecommendations) {
  name: 'Microsoft.FinOpsHubs.AzureResourceGraph'
  params: {
    app: newApp(hub, 'Microsoft.FinOpsHubs', 'AzureResourceGraph')
    core: core.outputs.metadata
  }
}

//------------------------------------------------------------------------------
// Custom recommendations
//------------------------------------------------------------------------------

module recommendations 'Microsoft.FinOpsHubs/Recommendations/app.bicep' = if (enableRecommendations) {
  name: 'Microsoft.FinOpsHubs.Recommendations'
  dependsOn: [
    azureResourceGraph
  ]
  params: {
    app: newApp(hub, 'Microsoft.FinOpsHubs', 'Recommendations')
    core: core.outputs.metadata
    ingestionQueries: ingestionQueries!.outputs.metadata // Safe: guarded by same enableRecommendations condition
    enableAHBRecommendations: enableAHBRecommendations
    enableSpotRecommendations: enableSpotRecommendations
  }
}

//------------------------------------------------------------------------------
// Remote hub app
//------------------------------------------------------------------------------

module remoteHub 'Microsoft.FinOpsHubs/RemoteHub/app.bicep' = if (!empty(remoteHubStorageKey)) {
  name: 'Microsoft.FinOpsHubs.RemoteHub'
  params: {
    app: newApp(hub, 'Microsoft.FinOpsHubs', 'RemoteHub')
    core: core.outputs.metadata
    remoteStorageKey: remoteHubStorageKey
    remoteHubStorageUri: remoteHubStorageUri
  }
}

//------------------------------------------------------------------------------
// Final touches
//------------------------------------------------------------------------------

// Delete old triggers and pipelines
module deleteOldResources 'fx/hub-deploymentScript.bicep' = {
  name: 'Microsoft.FinOpsHubs.DeleteOldResources'
  params: {
    app: core.outputs.app
    identityName: core.outputs.triggerManagerIdentityName
    scriptContent: loadTextContent('fx/scripts/Remove-OldResources.ps1')
    environmentVariables: [
      {
        name: 'DataFactorySubscriptionId'
        value: subscription().id
      }
      {
        name: 'DataFactoryResourceGroup'
        value: resourceGroup().name
      }
      {
        name: 'DataFactoryName'
        value: core.outputs.app.dataFactory
      }
    ]
  }
}

// Start all ADF triggers
module startTriggers 'fx/hub-initialize.bicep' = {
  name: 'Microsoft.FinOpsHubs.StartTriggers'
  dependsOn: [
    analytics
    recommendations
    deleteOldResources
    remoteHub
    cmManagedExports
  ]
  params: {
    app: core.outputs.app
    dataFactoryInstances: [
      core.outputs.app.dataFactory       // Microsoft.FinOpsHubs
      cmExports.outputs.app.dataFactory  // Microsoft.CostManagement
    ]
    identityName: core.outputs.triggerManagerIdentityName
    startAllTriggers: true
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
output dataFactoryName string = core.outputs.dataFactoryName

@description('Resource ID of the storage account created for the hub instance. This must be used when creating the Cost Management export.')
output storageAccountId string = resourceId('Microsoft.Storage/storageAccounts', core.outputs.storageAccountName)

@description('Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.')
output storageAccountName string = core.outputs.storageAccountName

@description('URL to use when connecting custom Power BI reports to your data.')
output storageUrlForPowerBI string = core.outputs.metadata.storageUrlForPowerBI

@description('The resource ID of the Data Explorer cluster.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output clusterId string = !useAzureDataExplorer ? '' : analytics.outputs.metadata.cluster.id

@description('The URI of the Data Explorer cluster.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output clusterUri string = useFabric ? fabricQueryUri : (!useAzureDataExplorer ? '' : analytics.outputs.metadata.cluster.uri)

@description('The name of the Data Explorer database used for ingesting data.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output ingestionDbName string = useFabric || useAzureDataExplorer ? analytics.outputs.metadata.databases.ingestion : ''

@description('The name of the Data Explorer database used for querying data.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output hubDbName string = useFabric || useAzureDataExplorer ? analytics.outputs.metadata.databases.hub : ''

@description('Object ID of the Data Factory managed identity. This will be needed when configuring managed exports.')
output managedIdentityId string = core.outputs.metadata.principalId

@description('Azure AD tenant ID. This will be needed when configuring managed exports.')
output managedIdentityTenantId string = tenant().tenantId
