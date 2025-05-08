// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

targetScope = 'resourceGroup'

@description('Optional. Name of the hub. Used to ensure unique resource names. Default: "finops-hub".')
param hubName string

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: Same as deployment.')
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

@description('Optional. Storage account to push data to for ingestion into a remote hub.')
param remoteHubStorageUri string = ''

@description('Optional. Storage account key to use when pushing data to a remote hub.')
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

// cSpell:ignore eventhouse
@description('Optional. Microsoft Fabric eventhouse query URI. Default: "" (do not use).')
param fabricQueryUri string = ''

@description('Optional. Number of capacity units for the Microsoft Fabric capacity. This is the number in your Fabric SKU (e.g., Trial = 1, F2 = 2, F64 = 64). This is used to manage parallelization in data pipelines. If you change capacity, please redeploy the template. Allowed values: 1 for the Fabric trial and 2-2048 based on the assigned Fabric capacity (e.g., F2-F2048). Default: 2.')
@minValue(1)
@maxValue(2048)
param fabricCapacityUnits int = 2

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

@description('Optional. Enable public access to FinOps hubs resources.  Default: true.')
param enablePublicAccess bool = true

@description('Optional. Address space for the workload. A /26 is required for the workload. Default: "10.20.30.0/26".')
param virtualNetworkAddressPrefix string = '10.20.30.0/26'


//==============================================================================
// Resources
//==============================================================================

module hub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    hubName: hubName
    location: location
    // eventGridLocation: eventGridLocation
    storageSku: storageSku
    enableInfrastructureEncryption: enableInfrastructureEncryption
    dataExplorerName: dataExplorerName
    dataExplorerSku: dataExplorerSku
    dataExplorerCapacity: dataExplorerCapacity
    fabricQueryUri: fabricQueryUri
    fabricCapacityUnits: fabricCapacityUnits
    tags: tags
    tagsByResource: tagsByResource
    scopesToMonitor: scopesToMonitor
    exportRetentionInDays: exportRetentionInDays
    ingestionRetentionInMonths: ingestionRetentionInMonths
    dataExplorerRawRetentionInDays: dataExplorerRawRetentionInDays
    dataExplorerFinalRetentionInMonths: dataExplorerFinalRetentionInMonths
    remoteHubStorageUri: remoteHubStorageUri
    remoteHubStorageKey: remoteHubStorageKey
    enablePublicAccess: enablePublicAccess
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
  }
}

//==============================================================================
// Outputs
//==============================================================================

@description('Name of the resource group.')
output name string = hubName

@description('Azure resource location resources were deployed to.')
output location string = location

@description('Name of the Data Factory instance.')
output dataFactoryName string = hub.outputs.dataFactoryName

@description('Resource ID of the deployed storage account.')
output storageAccountId string = hub.outputs.storageAccountId

@description('Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.')
output storageAccountName string = hub.outputs.storageAccountName

@description('URL to use when connecting custom Power BI reports to your data.')
output storageUrlForPowerBI string = hub.outputs.storageUrlForPowerBI

@description('Resource ID of the Data Explorer cluster.')
output clusterId string = hub.outputs.clusterId

@description('URI of the Data Explorer cluster.')
output clusterUri string = hub.outputs.clusterUri

@description('Name of the Data Explorer database used for ingesting data.')
output ingestionDbName string = hub.outputs.ingestionDbName

@description('Name of the Data Explorer database used for querying data.')
output hubDbName string = hub.outputs.hubDbName

@description('Object ID of the Data Factory managed identity. This will be needed when configuring managed exports.')
output managedIdentityId string = hub.outputs.managedIdentityId

@description('Azure AD tenant ID. This will be needed when configuring managed exports.')
output managedIdentityTenantId string = hub.outputs.managedIdentityTenantId
