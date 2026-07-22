// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the storage account.')
param storageAccountName string

@description('Required. Name of the storage account used for deployment scripts.')
param scriptStorageAccountName string

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).')
param location string = resourceGroup().location

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Optional. List of scope IDs to monitor and ingest cost for.')
param scopesToMonitor array

// cSpell:ignore msexport
@description('Optional. Number of days of data to retain in the msexports container. Default: 0.')
param msexportRetentionInDays int = 0

@description('Optional. Number of months of data to retain in the ingestion container. Default: 13.')
param ingestionRetentionInMonths int = 13

@description('Optional. Number of days of data to retain in the Data Explorer *_raw tables. Default: 0.')
param rawRetentionInDays int = 0

@description('Optional. Number of months of data to retain in the Data Explorer *_final_v* tables. Default: 13.')
param finalRetentionInMonths int = 13

@description('Required. Resource ID of the virtual network for running deployment scripts.')
param scriptSubnetId string

@description('Optional. Enable public access to the data lake.  Default: false.')
param enablePublicAccess bool

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

// Generate globally unique storage account name: 3-24 chars; lowercase letters/numbers only
var schemaFiles = {
  // cSpell:ignore actualcost, amortizedcost, focuscost, pricesheet, reservationdetails, reservationrecommendations, reservationtransactions
  'schemas/actualcost_c360-2025-04.json': loadTextContent('../schemas/actualcost_c360-2025-04.json')
  'schemas/amortizedcost_c360-2025-04.json': loadTextContent('../schemas/amortizedcost_c360-2025-04.json')
  'schemas/focuscost_1.0r2.json': loadTextContent('../schemas/focuscost_1.0r2.json')
  'schemas/focuscost_1.0.json': loadTextContent('../schemas/focuscost_1.0.json')
  'schemas/focuscost_1.0-preview(v1).json': loadTextContent('../schemas/focuscost_1.0-preview(v1).json')
  'schemas/pricesheet_2023-05-01_ea.json': loadTextContent('../schemas/pricesheet_2023-05-01_ea.json')
  'schemas/pricesheet_2023-05-01_mca.json': loadTextContent('../schemas/pricesheet_2023-05-01_mca.json')
  'schemas/reservationdetails_2023-03-01.json': loadTextContent('../schemas/reservationdetails_2023-03-01.json')
  'schemas/reservationrecommendations_2023-05-01_ea.json': loadTextContent('../schemas/reservationrecommendations_2023-05-01_ea.json')
  'schemas/reservationrecommendations_2023-05-01_mca.json': loadTextContent('../schemas/reservationrecommendations_2023-05-01_mca.json')
  'schemas/reservationtransactions_2023-05-01_ea.json': loadTextContent('../schemas/reservationtransactions_2023-05-01_ea.json')
  'schemas/reservationtransactions_2023-05-01_mca.json': loadTextContent('../schemas/reservationtransactions_2023-05-01_mca.json')
}

// Roles needed to upload files
// Storage Blob Data Contributor - used by deployment scripts to write data to blob storage
// Storage File Data Privileged Contributor - used by deployment scripts to write data to blob storage
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template#use-existing-storage-account
var blobUploadRbacRoles = [
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor
  '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Privileged Contributor - https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-file-data-privileged-contributor
]

//==============================================================================
// Resources
//==============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource scriptStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = if (!enablePublicAccess) {
  name: scriptStorageAccountName
}

//------------------------------------------------------------------------------
// Containers
//------------------------------------------------------------------------------

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

// TODO: Move to core module
module configContainer 'hub-storage.bicep' = {
  name: 'Microsoft.FinOpsHubs.Core_SchemaFiles'
  params: {
    container: 'config'
    files: schemaFiles

    // Hub context
    storageAccountName: storageAccount.name
    location: location
    tags: tags
    tagsByResource: tagsByResource
    blobManagerIdentityName: identity.name
    enablePublicAccess: enablePublicAccess
    scriptStorageAccountName: scriptStorageAccount.name
    scriptSubnetId: scriptSubnetId
  }
}

// TODO: Move to separate CM exports module
module exportContainer 'hub-storage.bicep' = {
  name: 'Microsoft.CostManagement.Exports_ExportContainer'
  params: {
    container: 'msexports'
    
    // Hub context
    storageAccountName: storageAccount.name
    enablePublicAccess: enablePublicAccess
  }
}

// TODO: Move to core module
module ingestionContainer 'hub-storage.bicep' = {
  name: 'Microsoft.FinOpsHubs.Core_IngestionContainer'
  params: {
    container: 'ingestion'
    
    // Hub context
    storageAccountName: storageAccount.name
    enablePublicAccess: enablePublicAccess
  }
}

//------------------------------------------------------------------------------
// Settings.json
//------------------------------------------------------------------------------

// Create managed identity to upload files
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${storageAccountName}_blobManager'
  tags: union(tags, tagsByResource[?'Microsoft.ManagedIdentity/userAssignedIdentities'] ?? {})
  location: location
}

// Assign access to the identity
resource identityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in blobUploadRbacRoles: {
  name: guid(storageAccount.id, role, identity.id)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

resource uploadSettings 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: '${storageAccountName}_uploadSettings'
  kind: 'AzurePowerShell'
  // cSpell:ignore chinaeast
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  tags: union(tags, tagsByResource[?'Microsoft.Resources/deploymentScripts'] ?? {})
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  dependsOn: [
    configContainer
    identityRoleAssignments
  ]
  properties: union(enablePublicAccess ? {} : {
    storageAccountSettings: {
      storageAccountName: scriptStorageAccount.name
    }
    containerSettings: {
      containerGroupName: '${scriptStorageAccount.name}cg'
      subnetIds: [
        {
          id: scriptSubnetId
        }
      ]
    }
  }, {
    azPowerShellVersion: '9.0'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        // cSpell:ignore ftkver
        name: 'ftkVersion'
        value: loadTextContent('./ftkver.txt')
      }
      {
        name: 'scopes'
        value: join(scopesToMonitor, '|')
      }
      {
        name: 'msexportRetentionInDays'
        value: string(msexportRetentionInDays)
      }
      {
        name: 'ingestionRetentionInMonths'
        value: string(ingestionRetentionInMonths)
      }
      {
        name: 'rawRetentionInDays'
        value: string(rawRetentionInDays)
      }
      {
        name: 'finalRetentionInMonths'
        value: string(finalRetentionInMonths)
      }
      {
        name: 'storageAccountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: 'config'
      }
    ]
    scriptContent: loadTextContent('./scripts/Copy-FileToAzureBlob.ps1')
  })
}

//==============================================================================
// Outputs
//==============================================================================

@description('The resource ID of the storage account.')
output resourceId string = storageAccount.id

@description('The name of the storage account.')
output name string = storageAccount.name

@description('The resource ID of the storage account.')
output scriptStorageAccountResourceId string = scriptStorageAccount.id

@description('The name of the storage account.')
output scriptStorageAccountName string = scriptStorageAccount.name

@description('The name of the container used for configuration settings.')
output configContainer string = configContainer.outputs.containerName

@description('The name of the container used for Cost Management exports.')
output exportContainer string = exportContainer.outputs.containerName

@description('The name of the container used for normalized data ingestion.')
output ingestionContainer string = ingestionContainer.outputs.containerName
