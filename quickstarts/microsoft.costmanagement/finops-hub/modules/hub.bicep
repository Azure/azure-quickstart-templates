// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

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

@description('Optional. Name of the Azure Data Explorer cluster to use for advanced analytics. If empty, Azure Data Explorer will not be deployed. Required to use with Power BI if you have more than $2-5M/mo in costs being monitored. Default: "" (do not use).')
param dataExplorerName string = ''

// https://learn.microsoft.com/azure/templates/microsoft.kusto/clusters?pivots=deployment-language-bicep#azuresku
@description('Optional. Name of the Azure Data Explorer SKU. Default: "Dev(No SLA)_Standard_D11_v2".')
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

@description('Optional. Number of nodes to use in the cluster. Allowed values: 1 for the Basic SKU tier and 2-1000 for Standard. Default: 1 for dev/test SKUs, 2 for standard SKUs.')
@minValue(1)
@maxValue(1000)
param dataExplorerCapacity int = 1

@description('Optional. Tags to apply to all resources. We will also add the cm-resource-parent tag for improved cost roll-ups in Cost Management.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Optional. List of scope IDs to monitor and ingest cost for.')
param scopesToMonitor array

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

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

// Add cm-resource-parent to group resources in Cost Management
var finOpsToolkitVersion = loadTextContent('ftkver.txt')
var resourceTags = union(tags, {
  'cm-resource-parent': '${resourceGroup().id}/providers/Microsoft.Cloud/hubs/${hubName}'
  'ftk-version': finOpsToolkitVersion
  'ftk-tool': 'FinOps hubs'
})

// Generate globally unique Data Factory name: 3-63 chars; letters, numbers, non-repeating dashes
var uniqueSuffix = uniqueString(hubName, resourceGroup().id)
var dataFactoryPrefix = '${replace(hubName, '_', '-')}-engine'
var dataFactorySuffix = '-${uniqueSuffix}'
var dataFactoryName = replace(
  '${take(dataFactoryPrefix, 63 - length(dataFactorySuffix))}${dataFactorySuffix}',
  '--',
  '-'
)

// Do not reference the dataExplorer deployment directly or indirectly to avoid a DeploymentNotFound error
var deployDataExplorer = !empty(dataExplorerName)
var safeDataExplorerName = !deployDataExplorer ? '' : dataExplorer.outputs.clusterName
var safeDataExplorerUri = !deployDataExplorer ? '' : dataExplorer.outputs.clusterUri
var safeDataExplorerId = !deployDataExplorer ? '' : dataExplorer.outputs.clusterId
var safeDataExplorerIngestionDb = !deployDataExplorer ? '' : dataExplorer.outputs.ingestionDbName
var safeDataExplorerIngestionCapacity =  !deployDataExplorer ? 1 : dataExplorer.outputs.clusterIngestionCapacity
var safeDataExplorerPrincipalId =  !deployDataExplorer ? '' : dataExplorer.outputs.principalId

// var eventGridPrefix = '${replace(hubName, '_', '-')}-ns'
// var eventGridSuffix = '-${uniqueSuffix}'
// var eventGridName = replace(
//   '${take(eventGridPrefix, 50 - length(eventGridSuffix))}${eventGridSuffix}',
//   '--',
//   '-'
// )

// EventGrid Contributor role
// var eventGridContributorRoleId = '1e241071-0855-49ea-94dc-649edcd759de'

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

// The last segment of the telemetryId is used to identify this module
var telemetryId = '00f120b5-2007-6120-0000-40b000000000'

//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Telemetry
// Used to anonymously count the number of times the template has been deployed
// and to track and fix deployment bugs to ensure the highest quality.
// No information about you or your cost data is collected.
//------------------------------------------------------------------------------

resource defaultTelemetry 'Microsoft.Resources/deployments@2022-09-01' = if (enableDefaultTelemetry) {
  name: 'pid-${telemetryId}-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      metadata: {
        _generator: {
          name: 'FinOps toolkit'
          version: finOpsToolkitVersion
        }
      }
      resources: []
    }
  }
}

//------------------------------------------------------------------------------
// Virtual network
//------------------------------------------------------------------------------

module vnet 'vnet.bicep' = {
  name: 'vnet'
  params: {
    hubName: hubName
    location: location
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
    tags: resourceTags
    tagsByResource: tagsByResource
  }
}

//------------------------------------------------------------------------------
// ADLSv2 storage account for staging and archive
//------------------------------------------------------------------------------

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    hubName: hubName
    uniqueSuffix: uniqueSuffix
    sku: storageSku
    location: location
    tags: resourceTags
    tagsByResource: tagsByResource
    enableInfrastructureEncryption: enableInfrastructureEncryption
    scopesToMonitor: scopesToMonitor
    msexportRetentionInDays: exportRetentionInDays
    ingestionRetentionInMonths: ingestionRetentionInMonths
    rawRetentionInDays: dataExplorerRawRetentionInDays
    finalRetentionInMonths: dataExplorerFinalRetentionInMonths
    virtualNetworkId: vnet.outputs.vNetId
    privateEndpointSubnetId: vnet.outputs.finopsHubSubnetId
    scriptSubnetId: vnet.outputs.scriptSubnetId
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
    location: location
    tags: resourceTags
    tagsByResource: tagsByResource
    dataFactoryName: dataFactory.name
    rawRetentionInDays: dataExplorerRawRetentionInDays
    virtualNetworkId: vnet.outputs.vNetId
    privateEndpointSubnetId: vnet.outputs.dataExplorerSubnetId
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
  tags: union(
    resourceTags,
    contains(tagsByResource, 'Microsoft.DataFactory/factories') ? tagsByResource['Microsoft.DataFactory/factories'] : {}
  )
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
    tags: resourceTags
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
    keyVaultName: keyVault.outputs.name
    remoteHubStorageUri: remoteHubStorageUri
    enablePublicAccess: enablePublicAccess
  }
}

//------------------------------------------------------------------------------
// Key Vault for storing secrets
//------------------------------------------------------------------------------

module keyVault 'keyVault.bicep' = {
  name: 'keyVault'
  params: {
    hubName: hubName
    uniqueSuffix: uniqueSuffix
    location: location
    tags: resourceTags
    tagsByResource: tagsByResource
    storageAccountKey: remoteHubStorageKey
    virtualNetworkId: vnet.outputs.vNetId
    privateEndpointSubnetId: vnet.outputs.finopsHubSubnetId
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
output dataFactorytName string = dataFactory.name

@description('Resource ID of the storage account created for the hub instance. This must be used when creating the Cost Management export.')
output storageAccountId string = storage.outputs.resourceId

@description('Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.')
output storageAccountName string = storage.outputs.name

@description('URL to use when connecting custom Power BI reports to your data.')
output storageUrlForPowerBI string = 'https://${storage.outputs.name}.dfs.${environment().suffixes.storage}/${storage.outputs.ingestionContainer}'

@description('The resource ID of the Data Explorer cluster.')
output clusterId string = !deployDataExplorer ? '' : dataExplorer.outputs.clusterId

@description('The URI of the Data Explorer cluster.')
output clusterUri string = !deployDataExplorer ? '' : dataExplorer.outputs.clusterUri

@description('The name of the Data Explorer database used for ingesting data.')
output ingestionDbName string = !deployDataExplorer ? '' : dataExplorer.outputs.ingestionDbName

@description('The name of the Data Explorer database used for querying data.')
output hubDbName string = !deployDataExplorer ? '' : dataExplorer.outputs.hubDbName

@description('Object ID of the Data Factory managed identity. This will be needed when configuring managed exports.')
output managedIdentityId string = dataFactory.identity.principalId

@description('Azure AD tenant ID. This will be needed when configuring managed exports.')
output managedIdentityTenantId string = tenant().tenantId
