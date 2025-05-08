// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the FinOps hub instance.')
param hubName string

@description('Required. Name of the Data Factory instance.')
param dataFactoryName string

@description('Required. The name of the Azure Key Vault instance.')
param keyVaultName string

@description('Required. The name of the Azure storage account instance.')
param storageAccountName string

@description('Required. The name of the container where Cost Management data is exported.')
param exportContainerName string

@description('Required. The name of the container where normalized data is ingested.')
param ingestionContainerName string

@description('Required. The name of the container where normalized data is ingested.')
param configContainerName string

@description('Optional. Name of the Azure Data Explorer cluster to use for advanced analytics, if applicable.')
param dataExplorerName string = ''

@description('Optional. Resource ID of the Azure Data Explorer cluster to use for advanced analytics, if applicable.')
param dataExplorerId string = ''

@description('Optional. ID of the Azure Data Explorer cluster system assigned managed identity, if applicable.')
param dataExplorerPrincipalId string = ''

// cSpell:ignore eventhouse
@description('Optional. URI of the Azure Data Explorer cluster or Microsoft Fabric eventhouse query endpoint to use for advanced analytics, if applicable.')
param dataExplorerUri string = ''

@description('Optional. Name of the Azure Data Explorer ingestion database. Default: "ingestion".')
param dataExplorerIngestionDatabase string = 'Ingestion'

@description('Optional. Azure Data Explorer ingestion capacity or Microsoft Fabric capacity units. Increase for non-dev/trial SKUs. Default: 1')
param dataExplorerIngestionCapacity int = 1

@description('Optional. The location to use for the managed identity and deployment script to auto-start triggers. Default = (resource group location).')
param location string = resourceGroup().location

@description('Optional. Remote storage account for ingestion dataset.')
param remoteHubStorageUri string

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Optional. Enable public access.')
param enablePublicAccess bool

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

var focusSchemaVersion = '1.0'
var exportSchemaVersion = '2023-05-01'
var reservationDetailsSchemaVersion = '2023-03-01'
// cSpell:ignore ftkver
var ftkVersion = loadTextContent('ftkver.txt')
var ftkReleaseUri = endsWith(ftkVersion, '-dev')
  ? 'https://github.com/microsoft/finops-toolkit/releases/latest/download'
  : 'https://github.com/microsoft/finops-toolkit/releases/download/v${ftkVersion}'
var exportApiVersion = '2023-07-01-preview'
var hubDataExplorerName = 'hubDataExplorer'

// cSpell:ignore timeframe
// Function to generate the body for a Cost Management export
func getExportBody(exportContainerName string, datasetType string, schemaVersion string, isMonthly bool, exportFormat string, compressionMode string, partitionData string, dataOverwriteBehavior string) string => '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${schemaVersion}", "filters": [] }, "granularity": "Daily" }, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{variables(\'exportName\')}", "name": "@{variables(\'exportName\')}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }'

func getExportBodyV2(exportContainerName string, datasetType string, schemaVersion string, isMonthly bool, exportFormat string, compressionMode string, partitionData string, dataOverwriteBehavior string, recommendationScope string, recommendationLookbackPeriod string, resourceType string) string => /*
  */ toLower(datasetType) == 'focuscost' ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${schemaVersion}", "filters": [] }, "granularity": "Daily" }, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : toLower(datasetType) == 'reservationdetails' ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${schemaVersion}", "filters": [] }, "granularity": "Daily" }, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : (toLower(datasetType) == 'pricesheet') || (toLower(datasetType) == 'reservationtransactions') ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${schemaVersion}", "filters": [] }}, "timeframe": "${isMonthly ? 'TheCurrentMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : toLower(datasetType) == 'reservationrecommendations' ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${schemaVersion}", "filters": [ { "name": "reservationScope", "value": "${recommendationScope}" }, { "name": "resourceType", "value": "${resourceType}" }, { "name": "lookBackPeriod", "value": "${recommendationLookbackPeriod}" }] }}, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : 'undefined'

var deployDataExplorer = !empty(dataExplorerId)
var useFabric = !deployDataExplorer && !empty(dataExplorerUri)

var datasetPropsDefault = {
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

var safeExportContainerName = replace('${exportContainerName}', '-', '_')
var safeIngestionContainerName = replace('${ingestionContainerName}', '-', '_')
var safeConfigContainerName = replace('${configContainerName}', '-', '_')
// cSpell:ignore vnet
var managedVnetName = 'default'

// Separator used to separate ingestion ID from file name for ingested files
var ingestionIdFileNameSeparator = '__'

// All hub triggers (used to auto-start)
var exportManifestAddedTriggerName = '${safeExportContainerName}_ManifestAdded'
var ingestionManifestAddedTriggerName = '${safeIngestionContainerName}_ManifestAdded'
var updateConfigTriggerName = '${safeConfigContainerName}_SettingsUpdated'
var dailyTriggerName = '${safeConfigContainerName}_DailySchedule'
var monthlyTriggerName = '${safeConfigContainerName}_MonthlySchedule'
var allHubTriggers = [
  exportManifestAddedTriggerName
  ingestionManifestAddedTriggerName
  updateConfigTriggerName
  dailyTriggerName
  monthlyTriggerName
]

// Roles needed to auto-start triggers
var autoStartRbacRoles = [
  '673868aa-7521-48a0-acc6-0f60742d39f5' // Data Factory contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#data-factory-contributor
]

// Roles for ADF to manage data in storage
// Does not include roles assignments needed against the export scope
var storageRbacRoles = [
  '17d1049b-9a84-46fb-8f53-869881c3d3ab' // Storage Account Contributor https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-account-contributor
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#reader
  '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9' // User Access Administrator https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator
]

//==============================================================================
// Resources
//==============================================================================

// Get data factory instance
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

// Get storage account instance
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

// Get keyvault instance
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (!empty(remoteHubStorageUri)) {
  name: keyVaultName
}

// cSpell:ignore azuretimezones
module azuretimezones 'azuretimezones.bicep' = {
  name: 'azuretimezones'
  params: {
    location: location
  }
}

resource managedVirtualNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if (!enablePublicAccess) {
  name: managedVnetName
  parent: dataFactory
  properties: {}
}

resource managedIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if (!enablePublicAccess) {
  name: 'ManagedIntegrationRuntime'
  parent: dataFactory
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: managedVnetName
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: location
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
  dependsOn: [
    managedVirtualNetwork
  ]
}

resource storageManagedPrivateEndpoint 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = if (!enablePublicAccess) {
  name: storageAccount.name
  parent: managedVirtualNetwork
  properties: {
    name: storageAccount.name
    groupId: 'dfs'
    privateLinkResourceId: storageAccount.id
    fqdns: [
      storageAccount.properties.primaryEndpoints.dfs
    ]
  }
}

module getStoragePrivateEndpointConnections 'storageEndpoints.bicep' = if (!enablePublicAccess) {
  name: 'GetStoragePrivateEndpointConnections'
  dependsOn: [
    storageManagedPrivateEndpoint
  ]
  params: {
    storageAccountName: storageAccount.name
  }
}

module approveStoragePrivateEndpointConnections 'storageEndpoints.bicep' = if (!enablePublicAccess) {
  name: 'ApproveStoragePrivateEndpointConnections'
  params: {
    storageAccountName: storageAccount.name
    privateEndpointConnections: getStoragePrivateEndpointConnections.outputs.privateEndpointConnections
  }
}

resource keyVaultManagedPrivateEndpoint 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = if (!empty(remoteHubStorageUri) && !enablePublicAccess) {
  name: keyVault.name
  parent: managedVirtualNetwork
  properties: {
    name: keyVault.name
    groupId: 'vault'
    privateLinkResourceId: keyVault.id
    fqdns: [
      keyVault.properties.vaultUri
    ]
  }
}

module getKeyVaultPrivateEndpointConnections 'keyVaultEndpoints.bicep' = if (!empty(remoteHubStorageUri) && !enablePublicAccess) {
  name: 'GetKeyVaultPrivateEndpointConnections'
  dependsOn: [
    keyVaultManagedPrivateEndpoint
  ]
  params: {
    keyVaultName: keyVault.name
  }
}

module approveKeyVaultPrivateEndpointConnections 'keyVaultEndpoints.bicep' = if (!empty(remoteHubStorageUri) && !enablePublicAccess) {
  name: 'ApproveKeyVaultPrivateEndpointConnections'
  params: {
    keyVaultName: keyVault.name
    privateEndpointConnections: getKeyVaultPrivateEndpointConnections.outputs.privateEndpointConnections
  }
}

resource dataExplorerManagedPrivateEndpoint 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = if (deployDataExplorer && !enablePublicAccess) {
  name: hubDataExplorerName
  parent: managedVirtualNetwork
  properties: {
    name: hubDataExplorerName
    groupId: 'cluster'
    privateLinkResourceId: dataExplorerId
    fqdns: [
      dataExplorerUri
    ]
  }
}

module getDataExplorerPrivateEndpointConnections 'dataExplorerEndpoints.bicep' = if (deployDataExplorer && !enablePublicAccess) {
  name: 'GetDataExplorerPrivateEndpointConnections'
  dependsOn: [
    dataExplorerManagedPrivateEndpoint
  ]
  params: {
    dataExplorerName: dataExplorerName
  }
}

module approveDataExplorerPrivateEndpointConnections 'dataExplorerEndpoints.bicep' = if (deployDataExplorer && !enablePublicAccess) {
  name: 'ApproveDataExplorerPrivateEndpointConnections'
  params: {
    dataExplorerName: dataExplorerName
    privateEndpointConnections: getDataExplorerPrivateEndpointConnections.outputs.privateEndpointConnections
  }
}

//------------------------------------------------------------------------------
// Identities and RBAC
//------------------------------------------------------------------------------

// Create managed identity to start/stop triggers
resource triggerManagerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${dataFactory.name}_triggerManager'
  location: location
  tags: union(tags, tagsByResource[?'Microsoft.ManagedIdentity/userAssignedIdentities'] ?? {})
}

resource triggerManagerRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in autoStartRbacRoles: {
  name: guid(dataFactory.id, role, triggerManagerIdentity.id)
  scope: dataFactory
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: triggerManagerIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

// Grant ADF identity access to manage data in storage
resource factoryIdentityStorageRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in storageRbacRoles: {
  name: guid(storageAccount.id, role, dataFactory.id)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: dataFactory.identity.principalId
    principalType: 'ServicePrincipal'
  }
}]

//------------------------------------------------------------------------------
// Delete old triggers and pipelines
//------------------------------------------------------------------------------

resource deleteOldResources 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${dataFactory.name}_deleteOldResources'
  // cSpell:ignore chinaeast2
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${triggerManagerIdentity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    triggerManagerRoleAssignments
  ]
  tags: union(tags, tagsByResource[?'Microsoft.Resources/deploymentScripts'] ?? {})
  properties: {
    azPowerShellVersion: '8.0'
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    scriptContent: loadTextContent('./scripts/Remove-OldResources.ps1')
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
        value: dataFactory.name
      }
    ]
  }
}

//------------------------------------------------------------------------------
// Stop all triggers before deploying
//------------------------------------------------------------------------------

resource stopTriggers 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${dataFactory.name}_stopTriggers'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${triggerManagerIdentity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    triggerManagerRoleAssignments
  ]
  tags: union(tags, tagsByResource[?'Microsoft.Resources/deploymentScripts'] ?? {})
  properties: {
    azPowerShellVersion: '8.0'
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    scriptContent: loadTextContent('./scripts/Start-Triggers.ps1')
    arguments: '-Stop'
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
        value: dataFactory.name
      }
      {
        name: 'Triggers'
        value: join(allHubTriggers, '|')
      }
    ]
  }
}

//------------------------------------------------------------------------------
// Linked services
//------------------------------------------------------------------------------

// cSpell:ignore linkedservices
// TODO: Move to the hub-app module
resource linkedService_keyVault 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (!empty(remoteHubStorageUri)) {
  name: keyVault.name
  parent: dataFactory
  dependsOn: enablePublicAccess ? [] : [managedIntegrationRuntime]
  properties: {
    annotations: []
    parameters: {}
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: reference('Microsoft.KeyVault/vaults/${keyVault.name}', '2023-02-01').vaultUri
    }
    connectVia: enablePublicAccess ? null : {
      referenceName: managedIntegrationRuntime.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

// TODO: Move to the hub-app module
resource linkedService_storageAccount 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: storageAccount.name
  parent: dataFactory
  dependsOn: enablePublicAccess ? [] : [managedIntegrationRuntime]
  properties: {
    annotations: []
    parameters: {}
    type: 'AzureBlobFS'
    typeProperties: {
      url: reference('Microsoft.Storage/storageAccounts/${storageAccount.name}', '2021-08-01').primaryEndpoints.dfs
    }
    connectVia: enablePublicAccess ? null : {
      referenceName: managedIntegrationRuntime.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource linkedService_dataExplorer 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (deployDataExplorer || useFabric) {
  name: hubDataExplorerName
  parent: dataFactory
  dependsOn: enablePublicAccess ? [] : [managedIntegrationRuntime]
  properties: {
    type: 'AzureDataExplorer'
    parameters: {
      database: {
        type: 'String'
        defaultValue: dataExplorerIngestionDatabase
      }
    }
    typeProperties: {
      endpoint: dataExplorerUri
      database: '@{linkedService().database}'
      tenant: dataFactory.identity.tenantId
      servicePrincipalId: dataFactory.identity.principalId
    }
    connectVia: enablePublicAccess ? null : {
      referenceName: managedIntegrationRuntime.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource linkedService_remoteHubStorage 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (!empty(remoteHubStorageUri)) {
  name: 'remoteHubStorage'
  parent: dataFactory
  dependsOn: enablePublicAccess ? [] : [managedIntegrationRuntime]
  properties: {
    annotations: []
    parameters: {}
    type: 'AzureBlobFS'
    typeProperties: {
      url: remoteHubStorageUri
      accountKey: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: linkedService_keyVault.name
          type: 'LinkedServiceReference'
        }
        secretName: '${toLower(hubName)}-storage-key'
      }
    }
    connectVia: enablePublicAccess ? null : {
      referenceName: managedIntegrationRuntime.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource linkedService_ftkRepo 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'ftkRepo'
  parent: dataFactory
  dependsOn: enablePublicAccess ? [] : [managedIntegrationRuntime]
  properties: {
    parameters: {
      filePath: {
        type: 'string'
      }
    }
    annotations: []
    type: 'HttpServer'
    typeProperties: {
      url: '@concat(\'https://github.com/microsoft/finops-toolkit/\', linkedService().filePath)'
      enableServerCertificateValidation: true
      authenticationType: 'Anonymous'
    }
    connectVia: enablePublicAccess ? null : {
      referenceName: managedIntegrationRuntime.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

//------------------------------------------------------------------------------
// Datasets
//------------------------------------------------------------------------------

resource dataset_config 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: safeConfigContainerName
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {
      fileName: {
        type: 'String'
        defaultValue: 'settings.json'
      }
      folderPath: {
        type: 'String'
        defaultValue: configContainerName
      }
    }
    type: 'Json'
    typeProperties: datasetPropsDefault
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_storageAccount.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_manifest 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'manifest'
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {
      fileName: {
        type: 'String'
      defaultValue: 'manifest.json'
      }
      folderPath: {
        type: 'String'
        defaultValue: exportContainerName
      }
    }
    type: 'Json'
    typeProperties: datasetPropsDefault
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_storageAccount.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_msexports 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: safeExportContainerName
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {
      blobPath: {
        type: 'String'
      }
    }
    type: 'DelimitedText'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileName: {
          value: '@{dataset().blobPath}'
          type: 'Expression'
        }
        fileSystem: safeExportContainerName
      }
      columnDelimiter: ','
      escapeChar: '"'
      quoteChar: '"'
      firstRowAsHeader: true
    }
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_storageAccount.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_msexports_gzip 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${safeExportContainerName}_gzip'
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {
      blobPath: {
        type: 'String'
      }
    }
    type: 'DelimitedText'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        fileName: {
          value: '@{dataset().blobPath}'
          type: 'Expression'
        }
        fileSystem: safeExportContainerName
      }
      columnDelimiter: ','
      escapeChar: '"'
      quoteChar: '"'
      firstRowAsHeader: true
      compressionCodec: 'Gzip'
    }
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_storageAccount.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_msexports_parquet 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${safeExportContainerName}_parquet'
  parent: dataFactory
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
        fileSystem: safeExportContainerName
      }
    }
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_storageAccount.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_ingestion 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: safeIngestionContainerName
  parent: dataFactory
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
        fileSystem: safeIngestionContainerName
      }
    }
    linkedServiceName: {
      parameters: {}
      referenceName: empty(remoteHubStorageUri) ? linkedService_storageAccount.name : linkedService_remoteHubStorage.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_ingestion_files 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${safeIngestionContainerName}_files'
  parent: dataFactory
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
        fileSystem: safeIngestionContainerName
        folderPath: {
          value: '@dataset().folderPath'
          type: 'Expression'
        }
      }
    }
    linkedServiceName: {
      parameters: {}
      referenceName: empty(remoteHubStorageUri) ? linkedService_storageAccount.name : linkedService_remoteHubStorage.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_dataExplorer 'Microsoft.DataFactory/factories/datasets@2018-06-01' = if (deployDataExplorer || useFabric) {
  name: hubDataExplorerName
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
        defaultValue: dataExplorerIngestionDatabase
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
        defaultValue: ftkVersion
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

//------------------------------------------------------------------------------
// Triggers
//------------------------------------------------------------------------------

// TODO: Create apps_PublishEvent pipeline { event, properties }

module trigger_ExportManifestAdded 'hub-event-trigger.bicep' = {
  name: 'Microsoft.FinOpsHubs.Core_ExportManifestAddedTrigger'
  dependsOn: [
    stopTriggers
  ]
  params: {
    dataFactoryName: dataFactory.name
    triggerName: exportManifestAddedTriggerName

    // TODO: Replace pipeline with event: 'Microsoft.CostManagement.Exports.ManifestAdded'
    pipelineName: pipeline_ExecuteExportsETL.name
    pipelineParameters: {
      folderPath: '@triggerBody().folderPath'
      fileName: '@triggerBody().fileName'
    }
    
    storageAccountName: storageAccount.name
    storageContainer: exportContainerName
    storagePathEndsWith: 'manifest.json'
  }
}

module trigger_IngestionManifestAdded 'hub-event-trigger.bicep' = if (deployDataExplorer) {
  name: 'Microsoft.FinOpsHubs.Core_IngestionManifestAddedTrigger'
  dependsOn: [
    stopTriggers
  ]
  params: {
    dataFactoryName: dataFactory.name
    triggerName: ingestionManifestAddedTriggerName

    // TODO: Replace pipeline with event: 'Microsoft.FinOpsHubs.Core.IngestionManifestAdded'
    pipelineName: pipeline_ExecuteIngestionETL.name
    pipelineParameters: {
      folderPath: '@triggerBody().folderPath'
    }
    
    storageAccountName: storageAccount.name
    storageContainer: ingestionContainerName
    storagePathEndsWith: 'manifest.json'
  }
}

module trigger_SettingsUpdated 'hub-event-trigger.bicep' = {
  name: 'Microsoft.FinOpsHubs.Core_SettingsUpdatedTrigger'
  dependsOn: [
    stopTriggers
  ]
  params: {
    dataFactoryName: dataFactory.name
    triggerName: updateConfigTriggerName

    // TODO: Replace pipeline with event: 'Microsoft.FinOpsHubs.Core.SettingsUpdated'
    pipelineName: pipeline_ConfigureExports.name
    pipelineParameters: {}
    
    storageAccountName: storageAccount.name
    storageContainer: configContainerName
    // TODO: Change this to startswith
    storagePathEndsWith: 'settings.json'
  }
}

resource trigger_DailySchedule 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: dailyTriggerName
  parent: dataFactory
  dependsOn: [
    stopTriggers
  ]
  properties: {
    pipelines: [
      {
        pipelineReference: {
          referenceName: pipeline_StartExportProcess.name
          type: 'PipelineReference'
        }
        parameters: {
          Recurrence: 'Daily'
        }
      }
    ]
    type: 'ScheduleTrigger'
    typeProperties: {
      recurrence: {
        frequency: 'Hour'
        interval: 24
        startTime: '2023-01-01T01:01:00'
        timeZone: azuretimezones.outputs.Timezone
      }
    }
  }
}

resource trigger_MonthlySchedule 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: monthlyTriggerName
  parent: dataFactory
  dependsOn: [
    stopTriggers
  ]
  properties: {
    pipelines: [
      {
        pipelineReference: {
          referenceName: pipeline_StartExportProcess.name
          type: 'PipelineReference'
        }
        parameters: {
          Recurrence: 'Monthly'
        }
      }
    ]
    type: 'ScheduleTrigger'
    typeProperties: {
      recurrence: {
        frequency: 'Month'
        interval: 1
        startTime: '2023-01-05T01:11:00'
        timeZone: azuretimezones.outputs.Timezone
        schedule: {
          monthDays: [
            2
            5
            19
          ]
        }
      }
    }
  }
}

//------------------------------------------------------------------------------
// Pipelines
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// config_InitializeHub pipeline
//------------------------------------------------------------------------------
@description('Initializes the hub instance based on the configuration settings.')
resource pipeline_InitializeHub 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = if (deployDataExplorer || useFabric) {
  name: '${safeConfigContainerName}_InitializeHub'
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
            referenceName: dataset_config.name
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
                  database: dataExplorerIngestionDatabase
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
                          ? '.show database ${dataExplorerIngestionDatabase} policy managed_identity'
                          : '.alter-merge database ${dataExplorerIngestionDatabase} policy managed_identity "[ { \'ObjectId\' : \'${dataExplorerPrincipalId}\', \'AllowedUsages\' : \'NativeIngestion\' }]"'
                        type: 'Expression'
                      }
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: dataExplorerIngestionDatabase
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
                        database: dataExplorerIngestionDatabase
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
                      command: '.set-or-replace PricingUnits <| externaldata(x_PricingUnitDescription: string, AccountTypes: string, x_PricingBlockSize: decimal, PricingUnit: string)[@"${ftkReleaseUri}/PricingUnits.csv"] with (format="csv", ignoreFirstRecord=true) | project-away AccountTypes'
                      commandTimeout: '00:20:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: dataExplorerIngestionDatabase
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
                        database: dataExplorerIngestionDatabase
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
                        database: dataExplorerIngestionDatabase
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
                        database: dataExplorerIngestionDatabase
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
// config_StartBackfillProcess pipeline
//------------------------------------------------------------------------------
@description('Runs the backfill job for each month based on retention settings.')
resource pipeline_StartBackfillProcess 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeConfigContainerName}_StartBackfillProcess'
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: {
                value: '@variables(\'fileName\')'
                type: 'Expression'
              }
              folderPath: {
                value: '@variables(\'folderPath\')'
                type: 'Expression'
              }
            }
          }
        }
      }
      { // Set backfill end date
        name: 'Set backfill end date'
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
          variableName: 'endDate'
          value: {
            value: '@addDays(startOfMonth(utcNow()), -1)'
            type: 'Expression'
          }
        }
      }
      { // Set backfill start date
        name: 'Set backfill start date'
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
          variableName: 'startDate'
          value: {
            value: '@subtractFromTime(startOfMonth(utcNow()), activity(\'Get Config\').output.firstRow.retention.ingestion.months, \'Month\')'
            type: 'Expression'
          }
        }
      }
      { // Set export start date
        name: 'Set export start date'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set backfill start date'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'thisMonth'
          value: {
            value: '@startOfMonth(variables(\'endDate\'))'
            type: 'Expression'
          }
        }
      }
      { // Set export end date
        name: 'Set export end date'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set export start date'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'nextMonth'
          value: {
            value: '@startOfMonth(subtractFromTime(variables(\'thisMonth\'), 1, \'Month\'))'
            type: 'Expression'
          }
        }
      }
      { // Every Month
        name: 'Every Month'
        type: 'Until'
        dependsOn: [
          {
            activity: 'Set export end date'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set backfill end date'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@less(variables(\'thisMonth\'), variables(\'startDate\'))'
            type: 'Expression'
          }
          activities: [
            {
              name: 'Update export start date'
              type: 'SetVariable'
              dependsOn: [
                {
                  activity: 'Backfill data'
                  dependencyConditions: [
                    'Completed'
                  ]
                }
              ]
              userProperties: []
              typeProperties: {
                variableName: 'thisMonth'
                value: {
                  value: '@variables(\'nextMonth\')'
                  type: 'Expression'
                }
              }
            }
            {
              name: 'Update export end date'
              type: 'SetVariable'
              dependsOn: [
                {
                  activity: 'Update export start date'
                  dependencyConditions: [
                    'Completed'
                  ]
                }
              ]
              userProperties: []
              typeProperties: {
                variableName: 'nextMonth'
                value: {
                  value: '@subtractFromTime(variables(\'thisMonth\'), 1, \'Month\')'
                  type: 'Expression'
                }
              }
            }
            {
              name: 'Backfill data'
              type: 'ExecutePipeline'
              dependsOn: []
              userProperties: []
              typeProperties: {
                pipeline: {
                  referenceName: pipeline_RunBackfillJob.name
                  type: 'PipelineReference'
                }
                waitOnCompletion: true
                parameters: {
                  StartDate: {
                    value: '@variables(\'thisMonth\')'
                    type: 'Expression'
                  }
                  EndDate: {
                    value: '@addDays(addToTime(variables(\'thisMonth\'), 1, \'Month\'), -1)'
                    type: 'Expression'
                  }
                }
              }
            }
          ]
          timeout: '0.02:00:00'
        }
      }
    ]
    concurrency: 1
    variables: {
      exportName: {
        type: 'String'
      }
      storageAccountId: {
        type: 'String'
        defaultValue: storageAccount.id
      }
      finOpsHub: {
        type: 'String'
        defaultValue: hubName
      }
      resourceManagementUri: {
        type: 'String'
        defaultValue: environment().resourceManager
      }
      fileName: {
        type: 'String'
        defaultValue: 'settings.json'
      }
      folderPath: {
        type: 'String'
        defaultValue: configContainerName
      }
      endDate: {
        type: 'String'
      }
      startDate: {
        type: 'String'
      }
      thisMonth: {
        type: 'String'
      }
      nextMonth: {
        type: 'String'
      }
    }
  }
}

//------------------------------------------------------------------------------
// config_RunBackfillJob pipeline
// Triggered by config_StartBackfillProcess pipeline
//------------------------------------------------------------------------------
@description('Creates and triggers exports for all defined scopes for the specified date range.')
resource pipeline_RunBackfillJob 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeConfigContainerName}_RunBackfillJob'
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: {
                value: '@variables(\'fileName\')'
                type: 'Expression'
              }
              folderPath: {
                value: '@variables(\'folderPath\')'
                type: 'Expression'
              }
            }
          }
        }
      }
      { // Set Scopes
        name: 'Set Scopes'
        description: 'Save scopes to test if it is an array'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Get Config'
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
          variableName: 'scopesArray'
          value: {
            value: '@activity(\'Get Config\').output.firstRow.scopes'
            type: 'Expression'
          }
        }
      }
      { // Set Scopes as Array
        name: 'Set Scopes as Array'
        description: 'Wraps a single scope object into an array to work around the PowerShell bug where single-item arrays are sometimes written as a single object instead of an array.'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Scopes'
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
          variableName: 'scopesArray'
          value: {
            value: '@createArray(activity(\'Get Config\').output.firstRow.scopes)'
            type: 'Expression'
          }
        }
      }
      { // Filter Invalid Scopes
        name: 'Filter Invalid Scopes'
        description: 'Remove any invalid scopes to avoid errors.'
        type: 'Filter'
        dependsOn: [
          {
            activity: 'Set Scopes'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Scopes as Array'
            dependencyConditions: [
              'Skipped'
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@variables(\'scopesArray\')'
            type: 'Expression'
          }
          condition: {
            value: '@and(not(empty(item().scope)), not(equals(item().scope, \'/\')))'
            type: 'Expression'
          }
        }
      }
      { // ForEach Export Scope
        name: 'ForEach Export Scope'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Filter Invalid Scopes'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Filter Invalid Scopes\').output.Value'
            type: 'Expression'
          }
          isSequential: true
          activities: [
            {
              name: 'Set backfill export name'
              type: 'SetVariable'
              dependsOn: []
              userProperties: []
              typeProperties: {
                variableName: 'exportName'
                value: {
                  // cSpell:ignore costdetails
                  value: '@toLower(concat(variables(\'finOpsHub\'), \'-monthly-costdetails\'))'
                  type: 'Expression'
                }
              }
            }
            {
              name: 'Trigger backfill export'
              type: 'WebActivity'
              dependsOn: [
                {
                  activity: 'Set backfill export name'
                  dependencyConditions: [
                    'Completed'
                  ]
                }
              ]
              policy: {
                timeout: '0.00:05:00'
                retry: 1
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                url: {
                  value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{variables(\'exportName\')}/run?api-version=${exportApiVersion}'
                  type: 'Expression'
                }
                method: 'POST'
                headers: {
                  'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunBackfill@${ftkVersion}'
                  'Content-Type': 'application/json'
                  ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                }
                body: '{"timePeriod" : { "from" : "@{pipeline().parameters.StartDate}", "to" : "@{pipeline().parameters.EndDate}" }}'
                authentication: {
                  type: 'MSI'
                  resource: {
                    value: '@variables(\'resourceManagementUri\')'
                    type: 'Expression'
                  }
                }
              }
            }
          ]
        }
      }
    ]
    concurrency: 1
    parameters: {
      StartDate: {
        type: 'string'
      }
      EndDate: {
        type: 'string'
      }
    }
    variables: {
      exportName: {
        type: 'String'
      }
      storageAccountId: {
        type: 'String'
        defaultValue: storageAccount.id
      }
      finOpsHub: {
        type: 'String'
        defaultValue: hubName
      }
      resourceManagementUri: {
        type: 'String'
        defaultValue: environment().resourceManager
      }
      fileName: {
        type: 'String'
        defaultValue: 'settings.json'
      }
      folderPath: {
        type: 'String'
        defaultValue: configContainerName
      }
      scopesArray: {
        type: 'Array'
      }
    }
  }
}

//------------------------------------------------------------------------------
// config_StartExportProcess pipeline
// Triggered by config_DailySchedule/MonthlySchedule triggers
//------------------------------------------------------------------------------
@description('Gets a list of all Cost Management exports configured for this hub based on the scopes defined in settings.json, then runs each export using the config_RunExportJobs pipeline.')
resource pipeline_StartExportProcess 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeConfigContainerName}_StartExportProcess'
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: {
                value: '@variables(\'fileName\')'
                type: 'Expression'
              }
              folderPath: {
                value: '@variables(\'folderPath\')'
                type: 'Expression'
              }
            }
          }
        }
      }
      { // Set Scopes
        name: 'Set Scopes'
        description: 'Save scopes to test if it is an array'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Get Config'
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
          variableName: 'scopesArray'
          value: {
            value: '@activity(\'Get Config\').output.firstRow.scopes'
            type: 'Expression'
          }
        }
      }
      { // Set Scopes as Array
        name: 'Set Scopes as Array'
        description: 'Wraps a single scope object into an array to work around the PowerShell bug where single-item arrays are sometimes written as a single object instead of an array.'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Scopes'
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
          variableName: 'scopesArray'
          value: {
            value: '@createArray(activity(\'Get Config\').output.firstRow.scopes)'
            type: 'Expression'
          }
        }
      }
      { // Filter Invalid Scopes
        name: 'Filter Invalid Scopes'
        description: 'Remove any invalid scopes to avoid errors.'
        type: 'Filter'
        dependsOn: [
          {
            activity: 'Set Scopes'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Scopes as Array'
            dependencyConditions: [
              'Succeeded'
              'Skipped'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@variables(\'scopesArray\')'
            type: 'Expression'
          }
          condition: {
            value: '@and(not(empty(item().scope)), not(equals(item().scope, \'/\')))'
            type: 'Expression'
          }
        }
      }
      { // ForEach Export Scope
        name: 'ForEach Export Scope'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Filter Invalid Scopes'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Filter Invalid Scopes\').output.Value'
            type: 'Expression'
          }
          isSequential: true
          activities: [
            {
              name: 'Get exports for scope'
              type: 'WebActivity'
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
                url: {
                  value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports?api-version=${exportApiVersion}'
                  type: 'Expression'
                }
                method: 'GET'
                authentication: {
                  type: 'MSI'
                  resource: {
                    value: '@variables(\'resourceManagementUri\')'
                    type: 'Expression'
                  }
                }
              }
            }
            {
              name: 'Run exports for scope'
              type: 'ExecutePipeline'
              dependsOn: [
                {
                  activity: 'Get exports for scope'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              userProperties: []
              typeProperties: {
                pipeline: {
                  referenceName: pipeline_RunExportJobs.name
                  type: 'PipelineReference'
                }
                waitOnCompletion: true
                parameters: {
                  ExportScopes: {
                    value: '@activity(\'Get exports for scope\').output.value'
                    type: 'Expression'
                  }
                  Recurrence: {
                    value: '@pipeline().parameters.Recurrence'
                    type: 'Expression'
                  }
                }
              }
            }
          ]
        }
      }
    ]
    concurrency: 1
    parameters: {
      Recurrence: {
        type: 'string'
        defaultValue: 'Daily'
      }
    }
    variables: {
      fileName: {
        type: 'String'
        defaultValue: 'settings.json'
      }
      folderPath: {
        type: 'String'
        defaultValue: configContainerName
      }
      finOpsHub: {
        type: 'String'
        defaultValue: hubName
      }
      resourceManagementUri: {
        type: 'String'
        defaultValue: environment().resourceManager
      }
      scopesArray: {
        type: 'Array'
      }
    }
  }
}

//------------------------------------------------------------------------------
// config_RunExportJobs pipeline
// Triggered by pipeline_StartExportProcess pipeline
//------------------------------------------------------------------------------
@description('Runs the specified Cost Management exports.')
resource pipeline_RunExportJobs 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeConfigContainerName}_RunExportJobs'
  parent: dataFactory
  dependsOn: [
    dataset_config
  ]
  properties: {
    activities: [
      {
        name: 'ForEach export scope'
        type: 'ForEach'
        dependsOn: []
        userProperties: []
        typeProperties: {
          items: {
            value: '@pipeline().parameters.exportScopes'
            type: 'Expression'
          }
          isSequential: true
          activities: [
            {
              name: 'If scheduled'
              type: 'IfCondition'
              dependsOn: []
              userProperties: []
              typeProperties: {
                expression: {
                  value: '@and( startswith(toLower(item().name), toLower(variables(\'hubName\'))), and(contains(string(item().properties.schedule), \'recurrence\'), equals(toLower(item().properties.schedule.recurrence), toLower(pipeline().parameters.Recurrence))))'
                  type: 'Expression'
                }
                ifTrueActivities: [
                  {
                    name: 'Trigger export'
                    type: 'WebActivity'
                    dependsOn: []
                    policy: {
                      timeout: '0.00:05:00'
                      retry: 0
                      retryIntervalInSeconds: 30
                      secureOutput: false
                      secureInput: false
                    }
                    userProperties: []
                    typeProperties: {
                      method: 'POST'
                      url: {
                        value: '@{replace(toLower(concat(variables(\'resourceManagementUri\'),item().id)), \'com//\', \'com/\')}/run?api-version=${exportApiVersion}'
                        type: 'Expression'
                      }
                      headers: {
                        'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs@${ftkVersion}'
                        ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                      }
                      body: ' '
                      authentication: {
                        type: 'MSI'
                        resource: {
                          value: '@variables(\'resourceManagementUri\')'
                          type: 'Expression'
                        }
                      }
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    ]
    concurrency: 1
    parameters: {
      ExportScopes: {
        type: 'array'
      }
      Recurrence: {
        type: 'string'
        defaultValue: 'Daily'
      }
    }
    variables: {
      resourceManagementUri: {
        type: 'String'
        defaultValue: environment().resourceManager
      }
    hubName: {
        type: 'String'
        defaultValue: hubName
      }
    }
  }
}

//------------------------------------------------------------------------------
// config_ConfigureExports pipeline
// Triggered by config_SettingsUpdated trigger
//------------------------------------------------------------------------------
@description('Creates Cost Management exports for supported scopes.')
resource pipeline_ConfigureExports 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeConfigContainerName}_ConfigureExports'
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: {
                value: '@variables(\'fileName\')'
                type: 'Expression'
              }
              folderPath: {
                value: '@variables(\'folderPath\')'
                type: 'Expression'
              }
            }
          }
        }
      }
      { // Save Scopes
        name: 'Save Scopes'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Get Config'
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
          variableName: 'scopesArray'
          value: {
            value: '@activity(\'Get Config\').output.firstRow.scopes'
            type: 'Expression'
          }
        }
      }
      { // Save Scopes as Array
        name: 'Save Scopes as Array'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Save Scopes'
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
          variableName: 'scopesArray'
          value: {
            value: '@array(activity(\'Get Config\').output.firstRow.scopes)'
            type: 'Expression'
          }
        }
      }
      { // Filter Invalid Scopes
        name: 'Filter Invalid Scopes'
        type: 'Filter'
        dependsOn: [
          {
            activity: 'Save Scopes'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Save Scopes as Array'
            dependencyConditions: [
              'Skipped'
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@variables(\'scopesArray\')'
            type: 'Expression'
          }
          condition: {
            value: '@and(not(empty(item().scope)), not(equals(item().scope, \'/\')))'
            type: 'Expression'
          }
        }
      }
      { // ForEach Export Scope
        name: 'ForEach Export Scope'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Filter Invalid Scopes'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Filter Invalid Scopes\').output.value'
            type: 'Expression'
          }
          isSequential: true
          activities: [
            {
              name: 'Set Export Type'
              type: 'SetVariable'
              dependsOn: []
              policy: {
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                variableName: 'exportScopeType'
                value: {
                  value: '@if(contains(toLower(item().scope), \'providers/microsoft.billing/billingaccounts\'), if(contains(toLower(item().scope), \':\'), \'mca\', \'ea\'), if(contains(toLower(item().scope), \'subscriptions/\'), \'subscription\', \'undefined\'))'
                  type: 'Expression'
                }
              }
            }
            {
              name: 'Switch Export Type'
              type: 'Switch'
              dependsOn: [
                {
                  activity: 'Set Export Type'
                  dependencyConditions: [ 'Succeeded' ]
                }
              ]
              userProperties: []
              typeProperties: {
                on: {
                  value: '@toLower(variables(\'exportScopeType\'))'
                  type: 'Expression'
                }
                cases: [
                  { // EA
                    value: 'ea'
                    activities: [
                      { // 'EA open month focus export'
                        name: 'EA open month focus export'
                        type: 'WebActivity'
                        dependsOn: [
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-costdetails\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'FocusCost', focusSchemaVersion, false, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsDaily@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                      { // 'EA closed month focus export'
                        name: 'EA closed month focus export'
                        type: 'WebActivity'
                        dependsOn: [
                          {
                            activity: 'EA open month focus export'
                            dependencyConditions: [ 'Succeeded' ]
                          }
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-costdetails\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'FocusCost', focusSchemaVersion, true, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsMonthly@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                      { // 'EA monthly pricesheet export'
                        name: 'EA monthly pricesheet export'
                        type: 'WebActivity'
                        dependsOn: [
                          {
                            activity: 'EA closed month focus export'
                            dependencyConditions: [ 'Succeeded' ]
                          }
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-pricesheet\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'Pricesheet', exportSchemaVersion, true, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.Prices@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                      {
                        name: 'Trigger EA monthly pricesheet export'
                        type: 'WebActivity'
                        dependsOn: [
                          {
                            activity: 'EA monthly pricesheet export'
                            dependencyConditions: [ 'Succeeded' ]
                          }
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 0
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          method: 'POST'
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-pricesheet\'))}/run?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.Prices@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          body: ' '
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                      { // 'EA daily reservation details export'
                        name: 'EA daily reservation details export'
                        type: 'WebActivity'
                        dependsOn: [
                          {
                            activity: 'EA monthly pricesheet export'
                            dependencyConditions: [ 'Succeeded' ]
                          }
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-reservationdetails\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'ReservationDetails', reservationDetailsSchemaVersion, false, 'CSV', 'None', 'true', 'CreateNewReport', '', '', '')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.ReservationDetails@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                      { // 'EA daily reservation transactions export'
                        name: 'EA daily reservation transactions export'
                        type: 'WebActivity'
                        dependsOn: [
                          {
                            activity: 'EA daily reservation details export'
                            dependencyConditions: [ 'Succeeded' ]
                          }
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-reservationtransactions\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'ReservationTransactions', exportSchemaVersion, false, 'CSV', 'None', 'true', 'CreateNewReport', '', '', '')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.ReservationTransactions@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                      { // 'EA daily recommendations shared last30day virtualmachines export'
                        name: 'EA daily shared 30day virtualmachines'
                        type: 'WebActivity'
                        dependsOn: [
                          {
                            activity: 'EA daily reservation transactions export'
                            dependencyConditions: [ 'Succeeded' ]
                          }
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-recommendations-shared-last30days-virtualmachines\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'ReservationRecommendations', exportSchemaVersion, false, 'CSV', 'None', 'true', 'CreateNewReport', 'Shared', 'Last30Days', 'VirtualMachines')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.ReservationRecommendations.VM.Shared.30d@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                    ]
                  }
                  { // subscription
                    value: 'subscription'
                    activities: [
                      { // 'Subscription open month focus export'
                        name: 'Subscription open month focus export'
                        type: 'WebActivity'
                        dependsOn: [
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-costdetails\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'FocusCost', focusSchemaVersion, false, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsDaily@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                      { // 'Subscription closed month focus export'
                        name: 'Subscription closed month focus export'
                        type: 'WebActivity'
                        dependsOn: [
                          {
                            activity: 'Subscription open month focus export'
                            dependencyConditions: [ 'Succeeded' ]
                          }
                        ]
                        policy: {
                          timeout: '0.00:05:00'
                          retry: 2
                          retryIntervalInSeconds: 30
                          secureOutput: false
                          secureInput: false
                        }
                        userProperties: []
                        typeProperties: {
                          url: {
                            value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-costdetails\'))}?api-version=${exportApiVersion}'
                            type: 'Expression'
                          }
                          method: 'PUT'
                          body: {
                            value: getExportBodyV2(exportContainerName, 'FocusCost', focusSchemaVersion, true, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                            type: 'Expression'
                          }
                          headers: {
                            'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsMonthly@${ftkVersion}'
                            ClientType: 'FinOpsToolkit.Hubs@${ftkVersion}'
                          }
                          authentication: {
                            type: 'MSI'
                            resource: {
                              value: '@variables(\'resourceManagementUri\')'
                              type: 'Expression'
                            }
                          }
                        }
                      }
                    ]
                  }
                  { // MCA
                    value: 'mca'
                    activities: [
                      {
                        name: 'Export Type Unsupported Error'
                        type: 'Fail'
                        dependsOn: []
                        userProperties: []
                        typeProperties: {
                          message: {
                            value: '@concat(\'MCA agreements are not supported for managed exports :\',variables(\'exportScope\'))'
                            type: 'Expression'
                          }
                          errorCode: 'ExportTypeUnsupported'
                        }
                      }
                    ]
                  }
                ]
                defaultActivities: [
                  {
                    name: 'Export Type Not Defined Error'
                    type: 'Fail'
                    dependsOn: []
                    userProperties: []
                    typeProperties: {
                      message: {
                        value: '@concat(\'Unable to determine the export scope type for :\',variables(\'exportScope\'))'
                        type: 'Expression'
                      }
                      errorCode: 'ExportTypeNotDefined'
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    ]
    concurrency: 1
    variables: {
      scopesArray: {
        type: 'Array'
      }
      exportName: {
        type: 'String'
      }
      exportScope: {
        type: 'String'
      }
      exportScopeType: {
        type: 'String'
      }
      storageAccountId: {
        type: 'String'
        defaultValue: storageAccount.id
      }
      finOpsHub: {
        type: 'String'
        defaultValue: hubName
      }
      resourceManagementUri: {
        type: 'String'
        defaultValue: environment().resourceManager
      }
      fileName: {
        type: 'String'
        defaultValue: 'settings.json'
      }
      folderPath: {
        type: 'String'
        defaultValue: configContainerName
      }
    }
  }
}

//------------------------------------------------------------------------------
// msexports_ExecuteETL pipeline
// Triggered by msexports_ManifestAdded trigger
//------------------------------------------------------------------------------
@description('Queues the msexports_ETL_ingestion pipeline.')
resource pipeline_ExecuteExportsETL 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeExportContainerName}_ExecuteETL'
  parent: dataFactory
  properties: {
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
      { // Read Manifest
        name: 'Read Manifest'
        description: 'Load the export manifest to determine the scope, dataset, and date range.'
        type: 'Lookup'
        dependsOn: [
          {
            activity: 'Wait'
            dependencyConditions: ['Completed']
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
            referenceName: dataset_manifest.name
            type: 'DatasetReference'
            parameters: {
              fileName: {
                value: '@pipeline().parameters.fileName'
                type: 'Expression'
              }
              folderPath: {
                value: '@pipeline().parameters.folderPath'
                type: 'Expression'
              }
            }
          }
        }
      }
      { // Set Has No Rows
        name: 'Set Has No Rows'
        description: 'Check the row count '
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Read Manifest'
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
          variableName: 'hasNoRows'
          value: {
            value: '@or(equals(activity(\'Read Manifest\').output.firstRow.blobCount, null), equals(activity(\'Read Manifest\').output.firstRow.blobCount, 0))'
            type: 'Expression'
          }
        }
      }
      { // Set Export Dataset Type
        name: 'Set Export Dataset Type'
        description: 'Save the dataset type from the export manifest.'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Read Manifest'
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
          variableName: 'exportDatasetType'
          value: {
            value: '@activity(\'Read Manifest\').output.firstRow.exportConfig.type'
            type: 'Expression'
          }
        }
      }
      { // Set MCA Column
        name: 'Set MCA Column'
        description: 'Determines if the dataset schema has channel-specific columns and saves the column name that only exists in MCA to determine if it is an MCA dataset.'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Export Dataset Type'
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
          variableName: 'mcaColumnToCheck'
          value: {
            // cSpell:ignore pricesheet, reservationtransactions, reservationrecommendations
            value: '@if(contains(createArray(\'pricesheet\', \'reservationtransactions\'), toLower(variables(\'exportDatasetType\'))), \'BillingProfileId\', if(equals(toLower(variables(\'exportDatasetType\')), \'reservationrecommendations\'), \'Net Savings\', null))'
            type: 'Expression'
          }
        }
      }
      { // Set Export Dataset Version
        name: 'Set Export Dataset Version'
        description: 'Save the dataset version from the export manifest.'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Read Manifest'
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
          variableName: 'exportDatasetVersion'
          value: {
            value: '@activity(\'Read Manifest\').output.firstRow.exportConfig.dataVersion'
            type: 'Expression'
          }
        }
      }
      { // Detect Channel
        name: 'Detect Channel'
        description: 'Determines what channel this export is from. Switch statement handles the different file types if the mcaColumnToCheck variable is set.'
        type: 'Switch'
        dependsOn: [
          {
            activity: 'Set Has No Rows'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set MCA Column'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Export Dataset Version'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          on: {
            value: '@if(or(empty(variables(\'mcaColumnToCheck\')), variables(\'hasNoRows\')), \'ignore\', last(array(split(activity(\'Read Manifest\').output.firstRow.blobs[0].blobName, \'.\'))))'
            type: 'Expression'
          }
          cases: [
            { // csv
              value: 'csv'
              activities: [
                {
                  name: 'Check for MCA Column in CSV'
                  description: 'Checks the dataset to determine if the applicable MCA-specific column exists.'
                  type: 'Lookup'
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
                    source: {
                      type: 'DelimitedTextSource'
                      storeSettings: {
                        type: 'AzureBlobFSReadSettings'
                        recursive: false
                        enablePartitionDiscovery: false
                      }
                      formatSettings: {
                        type: 'DelimitedTextReadSettings'
                      }
                    }
                    dataset: {
                      referenceName: dataset_msexports.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@activity(\'Read Manifest\').output.firstRow.blobs[0].blobName'
                          type: 'Expression'
                        }
                      }
                    }
                  }
                }
                {
                  name: 'Set Schema File with Channel in CSV'
                  type: 'SetVariable'
                  dependsOn: [
                    {
                      activity: 'Check for MCA Column in CSV'
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
                    variableName: 'schemaFile'
                    value: {
                      value: '@toLower(concat(variables(\'exportDatasetType\'), \'_\', variables(\'exportDatasetVersion\'), if(and(contains(activity(\'Check for MCA Column in CSV\').output, \'firstRow\'), contains(activity(\'Check for MCA Column in CSV\').output.firstRow, variables(\'mcaColumnToCheck\'))), \'_mca\', \'_ea\'), \'.json\'))'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
            { // gz
              value: 'gz'
              activities: [
                {
                  name: 'Check for MCA Column in Gzip CSV'
                  description: 'Checks the dataset to determine if the applicable MCA-specific column exists.'
                  type: 'Lookup'
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
                    source: {
                      type: 'DelimitedTextSource'
                      storeSettings: {
                        type: 'AzureBlobFSReadSettings'
                        recursive: false
                        enablePartitionDiscovery: false
                      }
                      formatSettings: {
                        type: 'DelimitedTextReadSettings'
                      }
                    }
                    dataset: {
                      referenceName: dataset_msexports_gzip.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@activity(\'Read Manifest\').output.firstRow.blobs[0].blobName'
                          type: 'Expression'
                        }
                      }
                    }
                  }
                }
                {
                  name: 'Set Schema File with Channel in Gzip CSV'
                  type: 'SetVariable'
                  dependsOn: [
                    {
                      activity: 'Check for MCA Column in Gzip CSV'
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
                    variableName: 'schemaFile'
                    value: {
                      value: '@toLower(concat(variables(\'exportDatasetType\'), \'_\', variables(\'exportDatasetVersion\'), if(and(contains(activity(\'Check for MCA Column in Gzip CSV\').output, \'firstRow\'), contains(activity(\'Check for MCA Column in Gzip CSV\').output.firstRow, variables(\'mcaColumnToCheck\'))), \'_mca\', \'_ea\'), \'.json\'))'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
            { // parquet
              value: 'parquet'
              activities: [
                {
                  name: 'Check for MCA Column in Parquet'
                  description: 'Checks the dataset to determine if the applicable MCA-specific column exists.'
                  type: 'Lookup'
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
                    source: {
                      type: 'ParquetSource'
                      storeSettings: {
                        type: 'AzureBlobFSReadSettings'
                        recursive: false
                        enablePartitionDiscovery: false
                      }
                      formatSettings: {
                        type: 'ParquetReadSettings'
                      }
                    }
                    dataset: {
                      referenceName: dataset_msexports_parquet.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@activity(\'Read Manifest\').output.firstRow.blobs[0].blobName'
                          type: 'Expression'
                        }
                      }
                    }
                  }
                }
                {
                  name: 'Set Schema File with Channel for Parquet'
                  type: 'SetVariable'
                  dependsOn: [
                    {
                      activity: 'Check for MCA Column in Parquet'
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
                    variableName: 'schemaFile'
                    value: {
                      value: '@toLower(concat(variables(\'exportDatasetType\'), \'_\', variables(\'exportDatasetVersion\'), if(and(contains(activity(\'Check for MCA Column in Parquet\').output, \'firstRow\'), contains(activity(\'Check for MCA Column in Parquet\').output.firstRow, variables(\'mcaColumnToCheck\'))), \'_mca\', \'_ea\'), \'.json\'))'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
          ]
          defaultActivities: [
            {
              name: 'Set Schema File'
              type: 'SetVariable'
              dependsOn: []
              policy: {
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                variableName: 'schemaFile'
                value: {
                  value: '@toLower(concat(variables(\'exportDatasetType\'), \'_\', variables(\'exportDatasetVersion\'), \'.json\'))'
                  type: 'Expression'
                }
              }
            }
          ]
        }
      }
      { // Set Scope
        name: 'Set Scope'
        description: 'Save the scope from the export manifest.'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Read Manifest'
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
          variableName: 'scope'
          value: {
            value: '@split(toLower(activity(\'Read Manifest\').output.firstRow.exportConfig.resourceId), \'/providers/microsoft.costmanagement/exports/\')[0]'
            type: 'Expression'
          }
        }
      }
      { // Set Date
        name: 'Set Date'
        description: 'Save the exported month from the export manifest.'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Read Manifest'
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
          variableName: 'date'
          value: {
            value: '@replace(substring(activity(\'Read Manifest\').output.firstRow.runInfo.startDate, 0, 7), \'-\', \'\')'
            type: 'Expression'
          }
        }
      }
      { // Error: ManifestReadFailed
        name: 'Failed to Read Manifest'
        type: 'Fail'
        dependsOn: [
          {
            activity: 'Set Date'
            dependencyConditions: ['Failed']
          }
          {
            activity: 'Set Export Dataset Type'
            dependencyConditions: ['Failed']
          }
          {
            activity: 'Set Scope'
            dependencyConditions: ['Failed']
          }
          {
            activity: 'Read Manifest'
            dependencyConditions: ['Failed']
          }
          {
            activity: 'Set Export Dataset Version'
            dependencyConditions: ['Failed']
          }
          {
            activity: 'Detect Channel'
            dependencyConditions: ['Failed']
          }
        ]
        userProperties: []
        typeProperties: {
          message: {
            value: '@concat(\'Failed to read the manifest file for this export run. Manifest path: \', pipeline().parameters.folderPath)'
            type: 'Expression'
          }
          errorCode: 'ManifestReadFailed'
        }
      }
      { // Check Schema
        name: 'Check Schema'
        description: 'Verify that the schema file exists in storage.'
        type: 'GetMetadata'
        dependsOn: [
          {
            activity: 'Set Scope'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Date'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Detect Channel'
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: {
                value: '@variables(\'schemaFile\')'
                type: 'Expression'
              }
              folderPath: '${configContainerName}/schemas'
            }
          }
          fieldList: ['exists']
          storeSettings: {
            type: 'AzureBlobFSReadSettings'
            recursive: true
            enablePartitionDiscovery: false
          }
          formatSettings: {
            type: 'JsonReadSettings'
          }
        }
      }
      { // Error: SchemaNotFound
        name: 'Schema Not Found'
        type: 'Fail'
        dependsOn: [
          {
            activity: 'Check Schema'
            dependencyConditions: ['Failed']
          }
        ]
        userProperties: []
        typeProperties: {
          message: {
            value: '@concat(\'The \', variables(\'schemaFile\'), \' schema mapping file was not found. Please confirm version \', variables(\'exportDatasetVersion\'), \' of the \', variables(\'exportDatasetType\'), \' dataset is supported by this version of FinOps hubs. You may need to upgrade to a newer release. To add support for another dataset, you can create a custom mapping file.\')'
            type: 'Expression'
          }
          errorCode: 'SchemaNotFound'
        }
      }
      { // Set Hub Dataset
        name: 'Set Hub Dataset'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Export Dataset Type'
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
          variableName: 'hubDataset'
          value: {
            value: '@if(equals(toLower(variables(\'exportDatasetType\')), \'focuscost\'), \'Costs\', if(equals(toLower(variables(\'exportDatasetType\')), \'pricesheet\'), \'Prices\', if(equals(toLower(variables(\'exportDatasetType\')), \'reservationdetails\'), \'CommitmentDiscountUsage\', if(equals(toLower(variables(\'exportDatasetType\')), \'reservationrecommendations\'), \'Recommendations\', if(equals(toLower(variables(\'exportDatasetType\')), \'reservationtransactions\'), \'Transactions\', if(equals(toLower(variables(\'exportDatasetType\')), \'actualcost\'), \'ActualCosts\', if(equals(toLower(variables(\'exportDatasetType\')), \'amortizedcost\'), \'AmortizedCosts\', toLower(variables(\'exportDatasetType\')))))))))'
            type: 'Expression'
          }
        }
      }
      { // Set Destination Folder
        name: 'Set Destination Folder'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Check Schema'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Hub Dataset'
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
          variableName: 'destinationFolder'
          value: {
            value: '@replace(concat(variables(\'hubDataset\'),\'/\',substring(variables(\'date\'), 0, 4),\'/\',substring(variables(\'date\'), 4, 2),\'/\',toLower(variables(\'scope\')), if(equals(variables(\'hubDataset\'), \'Recommendations\'), activity(\'Read Manifest\').output.firstRow.exportConfig.exportName, \'\')),\'//\',\'/\')'
            type: 'Expression'
          }
        }
      }
      { // For Each Blob
        name: 'For Each Blob'
        description: 'Loop thru each exported file listed in the manifest.'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Set Destination Folder'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@if(variables(\'hasNoRows\'), json(\'[]\'), activity(\'Read Manifest\').output.firstRow.blobs)'
            type: 'Expression'
          }
          batchCount: enablePublicAccess ? 30 : 4 // so we don't overload the managed runtime
          isSequential: false
          activities: [
            { // Execute
              name: 'Execute'
              description: 'Run the ingestion ETL pipeline.'
              type: 'ExecutePipeline'
              dependsOn: []
              policy: {
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                pipeline: {
                  referenceName: pipeline_ToIngestion.name
                  type: 'PipelineReference'
                }
                waitOnCompletion: true
                parameters: {
                  blobPath: {
                    value: '@item().blobName'
                    type: 'Expression'
                  }
                  destinationFolder: {
                    value: '@variables(\'destinationFolder\')'
                    type: 'Expression'
                  }
                  destinationFile: {
                    value: '@last(array(split(replace(replace(item().blobName, \'.gz\', \'\'), \'.csv\', \'.parquet\'), \'/\')))'
                    type: 'Expression'
                  }
                  ingestionId: {
                    value: '@activity(\'Read Manifest\').output.firstRow.runInfo.runId'
                    type: 'Expression'
                  }
                  schemaFile: {
                    value: '@variables(\'schemaFile\')'
                    type: 'Expression'
                  }
                  exportDatasetType: {
                    value: '@variables(\'exportDatasetType\')'
                    type: 'Expression'
                  }
                  exportDatasetVersion: {
                    value: '@variables(\'exportDatasetVersion\')'
                    type: 'Expression'
                  }
                }
              }
            }
          ]
        }
      }
      { // Copy Manifest
        name: 'Copy Manifest'
        description: 'Copy the manifest to the ingestion container to trigger ADX ingestion'
        type: 'Copy'
        dependsOn: [
          {
            activity: 'For Each Blob'
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
          sink: {
            type: 'JsonSink'
            storeSettings: {
              type: 'AzureBlobFSWriteSettings'
            }
            formatSettings: {
              type: 'JsonWriteSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: dataset_manifest.name
            type: 'DatasetReference'
            parameters: {
              fileName: 'manifest.json'
              folderPath: {
                value: '@pipeline().parameters.folderPath'
                type: 'Expression'
              }
            }
          }
        ]
        outputs: [
          {
            referenceName: dataset_manifest.name
            type: 'DatasetReference'
            parameters: {
              fileName: 'manifest.json'
              folderPath: {
                value: '@concat(\'${ingestionContainerName}/\', variables(\'destinationFolder\'))'
                type: 'Expression'
              }
            }
          }
        ]
      }
    ]
    parameters: {
      folderPath: {
        type: 'string'
      }
      fileName: {
        type: 'string'
      }
    }
    variables: {
      date: {
        type: 'String'
      }
      destinationFolder: {
        type: 'String'
      }
      exportDatasetType: {
        type: 'String'
      }
      exportDatasetVersion: {
        type: 'String'
      }
      hasNoRows: {
        type: 'Boolean'
      }
      hubDataset: {
        type: 'String'
      }
      mcaColumnToCheck: {
        type: 'String'
      }
      schemaFile: {
        type: 'String'
      }
      scope: {
        type: 'String'
      }
    }
    annotations: [
      'New export'
    ]
  }
}

//------------------------------------------------------------------------------
// msexports_ETL_ingestion pipeline
// Triggered by msexports_ExecuteETL
//------------------------------------------------------------------------------
@description('Transforms CSV data to a standard schema and converts to Parquet.')
resource pipeline_ToIngestion 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeExportContainerName}_ETL_${safeIngestionContainerName}'
  parent: dataFactory
  properties: {
    activities: [
      { // Get Existing Parquet Files
        name: 'Get Existing Parquet Files'
        description: 'Get the previously ingested files so we can remove any older data. This is necessary to avoid data duplication in reports.'
        type: 'GetMetadata'
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
          dataset: {
            referenceName: dataset_ingestion_files.name
            type: 'DatasetReference'
            parameters: {
              folderPath: '@pipeline().parameters.destinationFolder'
            }
          }
          fieldList: [
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
      { // Filter Out Current Exports
        name: 'Filter Out Current Exports'
        description: 'Remove existing files from the current export so those files do not get deleted.'
        type: 'Filter'
        dependsOn: [
          {
            activity: 'Get Existing Parquet Files'
            dependencyConditions: [
              'Completed'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@if(contains(activity(\'Get Existing Parquet Files\').output, \'childItems\'), activity(\'Get Existing Parquet Files\').output.childItems, json(\'[]\'))'
            type: 'Expression'
          }
          condition: {
            // cSpell:ignore endswith
            value: '@and(endswith(item().name, \'.parquet\'), not(startswith(item().name, concat(pipeline().parameters.ingestionId, \'${ingestionIdFileNameSeparator}\'))))'
            type: 'Expression'
          }
        }
      }
      { // Load Schema Mappings
        name: 'Load Schema Mappings'
        description: 'Get schema mapping file to use for the CSV to parquet conversion.'
        type: 'Lookup'
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: {
                value: '@toLower(pipeline().parameters.schemaFile)'
                type: 'Expression'
              }
              folderPath: '${configContainerName}/schemas'
            }
          }
        }
      }
      { // Error: SchemaLoadFailed
        name: 'Failed to Load Schema'
        type: 'Fail'
        dependsOn: [
          {
            activity: 'Load Schema Mappings'
            dependencyConditions: [
              'Failed'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          message: {
            value: '@concat(\'Unable to load the \', pipeline().parameters.schemaFile, \' schema file. Please confirm the schema and version are supported for FinOps hubs ingestion. Unsupported files will remain in the msexports container.\')'
            type: 'Expression'
          }
          errorCode: 'SchemaLoadFailed'
        }
      }
      { // Set Additional Columns
        name: 'Set Additional Columns'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Load Schema Mappings'
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
          variableName: 'additionalColumns'
          value: {
            value: '@intersection(array(json(concat(\'[{"name":"x_SourceProvider","value":"Microsoft"},{"name":"x_SourceName","value":"Cost Management"},{"name":"x_SourceType","value":"\', pipeline().parameters.exportDatasetVersion, \'"},{"name":"x_SourceVersion","value":"\', pipeline().parameters.exportDatasetVersion, \'"}\'))), activity(\'Load Schema Mappings\').output.firstRow.additionalColumns)'
            type: 'Expression'
          }
        }
      }
      { // For Each Old File
        name: 'For Each Old File'
        description: 'Loop thru each of the existing files from previous exports.'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Convert to Parquet'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Filter Out Current Exports'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Filter Out Current Exports\').output.Value'
            type: 'Expression'
          }
          activities: [
            { // Delete Old Ingested File
              name: 'Delete Old Ingested File'
              description: 'Delete the previously ingested files from older exports.'
              type: 'Delete'
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
                dataset: {
                  referenceName: dataset_ingestion.name
                  type: 'DatasetReference'
                  parameters: {
                    blobPath: {
                      value: '@concat(pipeline().parameters.destinationFolder, \'/\', item().name)'
                      type: 'Expression'
                    }
                  }
                }
                enableLogging: false
                storeSettings: {
                  type: 'AzureBlobFSReadSettings'
                  recursive: false
                  enablePartitionDiscovery: false
                }
              }
            }
          ]
        }
      }
      { // Set Destination Path
        name: 'Set Destination Path'
        type: 'SetVariable'
        dependsOn: []
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'destinationPath'
          value: {
            value: '@concat(pipeline().parameters.destinationFolder, \'/\', pipeline().parameters.ingestionId, \'${ingestionIdFileNameSeparator}\', pipeline().parameters.destinationFile)'
            type: 'Expression'
          }
        }
      }
      { // Convert to Parquet
        name: 'Convert to Parquet'
        description: 'Convert CSV to parquet and move the file to the ${ingestionContainerName} container.'
        type: 'Switch'
        dependsOn: [
          {
            activity: 'Set Destination Path'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Load Schema Mappings'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Additional Columns'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          on: {
            value: '@last(array(split(pipeline().parameters.blobPath, \'.\')))'
            type: 'Expression'
          }
          cases: [
            { // CSV
              value: 'csv'
              activities: [
                { // Convert CSV File
                  name: 'Convert CSV File'
                  type: 'Copy'
                  dependsOn: []
                  policy: {
                    timeout: '0.00:10:00'
                    retry: 0
                    retryIntervalInSeconds: 30
                    secureOutput: false
                    secureInput: false
                  }
                  userProperties: []
                  typeProperties: {
                    source: {
                      type: 'DelimitedTextSource'
                      additionalColumns: {
                        value: '@variables(\'additionalColumns\')'
                        type: 'Expression'
                      }
                      storeSettings: {
                        type: 'AzureBlobFSReadSettings'
                        recursive: true
                        enablePartitionDiscovery: false
                      }
                      formatSettings: {
                        type: 'DelimitedTextReadSettings'
                      }
                    }
                    sink: {
                      type: 'ParquetSink'
                      storeSettings: {
                        type: 'AzureBlobFSWriteSettings'
                      }
                      formatSettings: {
                        type: 'ParquetWriteSettings'
                        fileExtension: '.parquet'
                      }
                    }
                    enableStaging: false
                    parallelCopies: 1
                    validateDataConsistency: false
                    translator: {
                      value: '@activity(\'Load Schema Mappings\').output.firstRow.translator'
                      type: 'Expression'
                    }
                  }
                  inputs: [
                    {
                      referenceName: dataset_msexports.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@pipeline().parameters.blobPath'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                  outputs: [
                    {
                      referenceName: dataset_ingestion.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@variables(\'destinationPath\')'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                }
              ]
            }
            { // GZ
              value: 'gz'
              activities: [
                { // Convert GZip CSV File
                  name: 'Convert GZip CSV File'
                  type: 'Copy'
                  dependsOn: []
                  policy: {
                    timeout: '0.00:10:00'
                    retry: 0
                    retryIntervalInSeconds: 30
                    secureOutput: false
                    secureInput: false
                  }
                  userProperties: []
                  typeProperties: {
                    source: {
                      type: 'DelimitedTextSource'
                      additionalColumns: {
                        value: '@variables(\'additionalColumns\')'
                        type: 'Expression'
                      }
                      storeSettings: {
                        type: 'AzureBlobFSReadSettings'
                        recursive: true
                        enablePartitionDiscovery: false
                      }
                      formatSettings: {
                        type: 'DelimitedTextReadSettings'
                      }
                    }
                    sink: {
                      type: 'ParquetSink'
                      storeSettings: {
                        type: 'AzureBlobFSWriteSettings'
                      }
                      formatSettings: {
                        type: 'ParquetWriteSettings'
                        fileExtension: '.parquet'
                      }
                    }
                    enableStaging: false
                    parallelCopies: 1
                    validateDataConsistency: false
                    translator: {
                      value: '@activity(\'Load Schema Mappings\').output.firstRow.translator'
                      type: 'Expression'
                    }
                  }
                  inputs: [
                    {
                      referenceName: dataset_msexports_gzip.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@pipeline().parameters.blobPath'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                  outputs: [
                    {
                      referenceName: dataset_ingestion.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@variables(\'destinationPath\')'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                }
              ]
            }
            { // Parquet
              value: 'parquet'
              activities: [
                { // Move Parquet File
                  name: 'Move Parquet File'
                  type: 'Copy'
                  dependsOn: []
                  policy: {
                    timeout: '0.00:05:00'
                    retry: 0
                    retryIntervalInSeconds: 30
                    secureOutput: false
                    secureInput: false
                  }
                  userProperties: []
                  typeProperties: {
                    source: {
                      type: 'ParquetSource'
                      additionalColumns: {
                        value: '@variables(\'additionalColumns\')'
                        type: 'Expression'
                      }
                      storeSettings: {
                        type: 'AzureBlobFSReadSettings'
                        recursive: true
                        enablePartitionDiscovery: false
                      }
                      formatSettings: {
                        type: 'ParquetReadSettings'
                      }
                    }
                    sink: {
                      type: 'ParquetSink'
                      storeSettings: {
                        type: 'AzureBlobFSWriteSettings'
                      }
                      formatSettings: {
                        type: 'ParquetWriteSettings'
                        fileExtension: '.parquet'
                      }
                    }
                    enableStaging: false
                    parallelCopies: 1
                    validateDataConsistency: false
                  }
                  inputs: [
                    {
                      referenceName: dataset_msexports_parquet.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@pipeline().parameters.blobPath'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                  outputs: [
                    {
                      referenceName: dataset_ingestion.name
                      type: 'DatasetReference'
                      parameters: {
                        blobPath: {
                          value: '@variables(\'destinationPath\')'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                }
              ]
            }
          ]
          defaultActivities: [
            { // Error: UnsupportedFileType
              name: 'Unsupported File Type'
              type: 'Fail'
              dependsOn: []
              userProperties: []
              typeProperties: {
                message: {
                  value: '@concat(\'Unable to ingest the specified export file because the file type is not supported. File: \', pipeline().parameters.blobPath)'
                  type: 'Expression'
                }
                errorCode: 'UnsupportedExportFileType'
              }
            }
          ]
        }
      }
      { // Read Hub Config
        name: 'Read Hub Config'
        description: 'Read the hub config to determine if the export should be retained.'
        type: 'Lookup'
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: 'settings.json'
              folderPath: configContainerName
            }
          }
        }
      }
      { // If Not Retaining Exports
        name: 'If Not Retaining Exports'
        description: 'If the msexports retention period <= 0, delete the source file. The main reason to keep the source file is to allow for troubleshooting and reprocessing in the future.'
        type: 'IfCondition'
        dependsOn: [
          {
            activity: 'Convert to Parquet'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Read Hub Config'
            dependencyConditions: [
              'Completed'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@lessOrEquals(coalesce(activity(\'Read Hub Config\').output.firstRow.retention.msexports.days, 0), 0)'
            type: 'Expression'
          }
          ifTrueActivities: [
            { // Delete Source File
              name: 'Delete Source File'
              description: 'Delete the exported data file to keep storage costs down. This file is not referenced by any reporting systems.'
              type: 'Delete'
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
                dataset: {
                  referenceName: dataset_msexports_parquet.name
                  type: 'DatasetReference'
                  parameters: {
                    blobPath: {
                      value: '@pipeline().parameters.blobPath'
                      type: 'Expression'
                    }
                  }
                }
                enableLogging: false
                storeSettings: {
                  type: 'AzureBlobFSReadSettings'
                  recursive: true
                  enablePartitionDiscovery: false
                }
              }
            }
          ]
        }
      }
    ]
    parameters: {
      blobPath: {
        type: 'String'
      }
      destinationFile: {
        type: 'string'
      }
      destinationFolder: {
        type: 'string'
      }
      ingestionId: {
        type: 'string'
      }
      schemaFile: {
        type: 'string'
      }
      exportDatasetType: {
        type: 'string'
      }
      exportDatasetVersion: {
        type: 'string'
      }
    }
    variables: {
      additionalColumns: {
        type: 'Array'
      }
      destinationPath: {
        type: 'String'
      }
    }
    annotations: []
  }
}

//------------------------------------------------------------------------------
// ingestion_ETL_dataExplorer pipeline
// Triggered by ingestion_ExecuteETL
//------------------------------------------------------------------------------
@description('Ingests parquet data into an Azure Data Explorer cluster.')
resource pipeline_ToDataExplorer 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = if (deployDataExplorer || useFabric) {
  name: '${safeIngestionContainerName}_ETL_dataExplorer'
  parent: dataFactory
  properties: {
    activities: [
      { // Read Hub Config
        name: 'Read Hub Config'
        description: 'Read the hub config to determine how long data should be retained.'
        type: 'Lookup'
        dependsOn: [
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
            referenceName: dataset_config.name
            type: 'DatasetReference'
            parameters: {
              fileName: 'settings.json'
              folderPath: configContainerName
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
                        database: dataExplorerIngestionDatabase
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
                        value: '@concat(\'.ingest into table \', pipeline().parameters.table, \' ("abfss://${ingestionContainerName}@${storageAccount.name}.dfs.${environment().suffixes.storage}/\', pipeline().parameters.folderPath, \'/\', pipeline().parameters.fileName, \';${useFabric ? 'impersonate' : 'managed_identity=system'}") with (format="parquet", ingestionMappingReference="\', pipeline().parameters.table, \'_mapping", tags="[\\"drop-by:\', pipeline().parameters.ingestionId, \'\\", \\"drop-by:\', pipeline().parameters.folderPath, \'/\', pipeline().parameters.originalFileName, \'\\", \\"drop-by:ftk-version-${ftkVersion}\\"]"); print Success = assert(iff(toscalar($command_results | project-keep HasErrors) == false, true, false), "Ingestion Failed")\')'
                        type: 'Expression'
                      }
                      commandTimeout: '01:00:00'
                    }
                    linkedServiceName: {
                      referenceName: linkedService_dataExplorer.name
                      type: 'LinkedServiceReference'
                      parameters: {
                        database: dataExplorerIngestionDatabase
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
                        database: dataExplorerIngestionDatabase
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
resource pipeline_ExecuteIngestionETL 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = if (deployDataExplorer || useFabric) {
  name: '${safeIngestionContainerName}_ExecuteETL'
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
            referenceName: dataset_ingestion_files.name
            type: 'DatasetReference'
            parameters: {
              folderPath: '@variables(\'containerFolderPath\')'
            }
          }
          fieldList: [
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
            value: '@if(contains(activity(\'Get Existing Parquet Files\').output, \'childItems\'), activity(\'Get Existing Parquet Files\').output.childItems, json(\'[]\'))'
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
                    value: '@last(array(split(item().name, \'${ingestionIdFileNameSeparator}\')))'
                    type: 'Expression'
                  }
                  ingestionId: {
                    value: '@concat(first(array(split(item().name, \'${ingestionIdFileNameSeparator}\'))), \'_\', variables(\'timestamp\'))'
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

//------------------------------------------------------------------------------
// Start all triggers
//------------------------------------------------------------------------------

resource startTriggers 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${dataFactory.name}_startTriggers'
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  tags: union(tags, tagsByResource[?'Microsoft.Resources/deploymentScripts'] ?? {})
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${triggerManagerIdentity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    triggerManagerRoleAssignments
    trigger_ExportManifestAdded
    trigger_IngestionManifestAdded
    trigger_SettingsUpdated
    trigger_DailySchedule
    trigger_MonthlySchedule
  ]
  properties: {
    azPowerShellVersion: '8.0'
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    scriptContent: loadTextContent('./scripts/Start-Triggers.ps1')
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
        value: dataFactory.name
      }
      {
        name: 'Triggers'
        value: join(allHubTriggers, '|')
      }
      {
        name: 'Pipelines'
        value: join([ pipeline_InitializeHub.name ], '|')
      }
    ]
  }
}

//==============================================================================
// Outputs
//==============================================================================

@description('The Resource ID of the Data factory.')
output resourceId string = dataFactory.id

@description('The Name of the Azure Data Factory instance.')
output name string = dataFactory.name
