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

@description('Optional. The location to use for the managed identity and deployment script to auto-start triggers. Default = (resource group location).')
param location string = resourceGroup().location

@description('Optional. Remote storage account for ingestion dataset.')
param remoteHubStorageUri string

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

var focusSchemaVersion = '1.0'
var ftkVersion = loadTextContent('ftkver.txt')
var exportApiVersion = '2023-07-01-preview'

// Function to generate the body for a Cost Management export
func getExportBody(exportContainerName string, datasetType string, schemaVersion string, isMonthly bool, exportFormat string, compressionMode string, partitionData string, dataOverwriteBehavior string) string => '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${schemaVersion}", "filters": [] }, "granularity": "Daily" }, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{variables(\'exportName\')}", "name": "@{variables(\'exportName\')}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }'

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

// All hub triggers (used to auto-start)
var fileAddedExportTriggerName = '${safeExportContainerName}_FileAdded'
var updateConfigTriggerName = '${safeConfigContainerName}_SettingsUpdated'
var dailyTriggerName = '${safeConfigContainerName}_DailySchedule'
var monthlyTriggerName = '${safeConfigContainerName}_MonthlySchedule'
var allHubTriggers = [
  fileAddedExportTriggerName
  updateConfigTriggerName
  dailyTriggerName
  monthlyTriggerName
]

// Roles needed to auto-start triggers
var autoStartRbacRoles = [
  '673868aa-7521-48a0-acc6-0f60742d39f5' // Data Factory contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#data-factory-contributor
  'e40ec5ca-96e0-45a2-b4ff-59039f2c2b59' // Managed Identity Contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#managed-identity-contributor
]

// Storage roles needed for ADF to create CM exports and process the output
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
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

module azuretimezones 'azuretimezones.bicep' = {
  name: 'azuretimezones'
  params: {
    location: location
  }
}

//------------------------------------------------------------------------------
// Identities and RBAC
//------------------------------------------------------------------------------

// Create managed identity to start/stop triggers
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${dataFactory.name}_triggerManager'
  location: location
  tags: union(tags, contains(tagsByResource, 'Microsoft.ManagedIdentity/userAssignedIdentities') ? tagsByResource['Microsoft.ManagedIdentity/userAssignedIdentities'] : {})
}

resource identityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in autoStartRbacRoles: {
  name: guid(dataFactory.id, role, identity.id)
  scope: dataFactory
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

// Create managed identity to manage exports in cost management
resource pipelineIdentityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in storageRbacRoles: {
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
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    identityRoleAssignments
  ]
  tags: union(tags, contains(tagsByResource, 'Microsoft.Resources/deploymentScripts') ? tagsByResource['Microsoft.Resources/deploymentScripts'] : {})
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
      '${identity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    identityRoleAssignments
  ]
  tags: tags
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

resource linkedService_keyVault 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: keyVault.name
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {}
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: reference('Microsoft.KeyVault/vaults/${keyVault.name}', '2023-02-01').vaultUri
    }
  }
}

resource linkedService_storageAccount 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: storageAccount.name
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {}
    type: 'AzureBlobFS'
    typeProperties: {
      url: reference('Microsoft.Storage/storageAccounts/${storageAccount.name}', '2021-08-01').primaryEndpoints.dfs
    }
  }
}

resource linkedService_remoteHubStorage 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (!empty(remoteHubStorageUri)) {
  name: 'remoteHubStorage'
  parent: dataFactory
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

//------------------------------------------------------------------------------
// Triggers
//------------------------------------------------------------------------------

// Create trigger
resource trigger_FileAdded 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: fileAddedExportTriggerName
  parent: dataFactory
  dependsOn: [
    stopTriggers
  ]
  properties: {
    annotations: []
    pipelines: [
      {
        pipelineReference: {
          referenceName: pipeline_ExecuteETL.name
          type: 'PipelineReference'
        }
        parameters: {
          folderPath: '@triggerBody().folderPath'
          fileName: '@triggerBody().fileName'
        }
      }
    ]
    type: 'BlobEventsTrigger'
    typeProperties: {
      blobPathBeginsWith: '/${exportContainerName}/blobs/'
      blobPathEndsWith: 'manifest.json'
      ignoreEmptyBlobs: true
      scope: storageAccount.id
      events: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }
}

resource trigger_SettingsUpdated 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: updateConfigTriggerName
  parent: dataFactory
  dependsOn: [
    stopTriggers
  ]
  properties: {
    annotations: []
    pipelines: [
      {
        pipelineReference: {
          referenceName: pipeline_ConfigureExports.name
          type: 'PipelineReference'
        }
      }
    ]
    type: 'BlobEventsTrigger'
    typeProperties: {
      blobPathBeginsWith: '/${configContainerName}/blobs/'
      blobPathEndsWith: 'settings.json'
      ignoreEmptyBlobs: true
      scope: storageAccount.id
      events: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
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
// config_StartBackfillProcess pipeline
//------------------------------------------------------------------------------
@description('Runs the backfill job for each month based on retention settings.')
resource pipeline_StartBackfillProcess 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeConfigContainerName}_StartBackfillProcess'
  parent: dataFactory
  properties: {
    activities: [
      {
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
      {
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
      {
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
      {
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
      {
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
      {
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
          timeout: '0.12:00:00'
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
                  value: '@and(equals(toLower(item().properties.schedule.recurrence), toLower(pipeline().parameters.Recurrence)),startswith(toLower(item().name), toLower(variables(\'hubName\'))))'
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
                      url: {
                        value: '@{replace(toLower(concat(variables(\'resourceManagementUri\'),item().id)), \'com//\', \'com/\')}/run?api-version=${exportApiVersion}'
                        type: 'Expression'
                      }
                      method: 'POST'
                      headers: {
                        'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs@${ftkVersion}'
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
@description('Creates Cost Management exports for all scopes.')
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
            { // 'Create or update open month focus export'
              name: 'Create or update open month focus export'
              type: 'WebActivity'
              dependsOn: [
                {
                  activity: 'Set open month focus export name'
                  dependencyConditions: [
                    'Succeeded'
                  ]
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
                  value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{variables(\'exportName\')}?api-version=${exportApiVersion}'
                  type: 'Expression'
                }
                method: 'PUT'
                body: {
                  value: getExportBody(exportContainerName, 'FocusCost', focusSchemaVersion, false, 'Parquet', 'Snappy', 'true', 'CreateNewReport')
                  type: 'Expression'
                }
                authentication: {
                  type: 'MSI'
                  resource: {
                    value: '@variables(\'ResourceManagementUri\')'
                    type: 'Expression'
                  }
                }
              }
            }
            { // 'Set open month focus export name'
              name: 'Set open month focus export name'
              type: 'SetVariable'
              dependsOn: []
              policy: {
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                variableName: 'exportName'
                value: {
                  value: '@toLower(concat(variables(\'finOpsHub\'), \'-daily-costdetails\'))'
                  type: 'Expression'
                }
              }
            }
            { // 'Create or update closed month focus export'
              name: 'Create or update closed month focus export'
              type: 'WebActivity'
              dependsOn: [
                {
                  activity: 'Set closed month focus export name'
                  dependencyConditions: [
                    'Succeeded'
                  ]
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
                  value: '@{variables(\'ResourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{variables(\'exportName\')}?api-version=${exportApiVersion}'
                  type: 'Expression'
                }
                method: 'PUT'
                body: {
                  value: getExportBody(exportContainerName, 'FocusCost', focusSchemaVersion, true, 'Parquet', 'Snappy', 'true', 'CreateNewReport')
                  type: 'Expression'
                }
                authentication: {
                  type: 'MSI'
                  resource: {
                    value: '@variables(\'ResourceManagementUri\')'
                    type: 'Expression'
                  }
                }
              }
            }
            { // 'Set closed month focus export name'
              name: 'Set closed month focus export name'
              type: 'SetVariable'
              dependsOn: [
                {
                  activity: 'Create or update open month focus export'
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
                variableName: 'exportName'
                value: {
                  value: '@toLower(concat(variables(\'finOpsHub\'), \'-monthly-costdetails\'))'
                  type: 'Expression'
                }
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
// Triggered by msexports_FileAdded trigger
//------------------------------------------------------------------------------
@description('Queues the msexports_ETL_ingestion pipeline.')
resource pipeline_ExecuteETL 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeExportContainerName}_ExecuteETL'
  parent: dataFactory
  properties: {
    activities: [
      { // Wait
        name: 'Wait'
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
      { // Set Dataset Type
        name: 'Set Dataset Type'
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
          variableName: 'datasetType'
          value: {
            value: '@toLower(activity(\'Read Manifest\').output.firstRow.exportConfig.type)'
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
            activity: 'Set Dataset Type'
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
            value: '@if(contains(createArray(\'pricesheet\', \'reservationtransactions\'), variables(\'datasetType\')), \'BillingProfileId\', if(equals(variables(\'datasetType\'), \'reservationrecommendations\'), \'Net Savings\', null))'
            type: 'Expression'
          }
        }
      }
      { // Set Dataset Version
        name: 'Set Dataset Version'
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
          variableName: 'datasetVersion'
          value: {
            value: '@activity(\'Read Manifest\').output.firstRow.exportConfig.dataVersion'
            type: 'Expression'
          }
        }
      }
      { // Detect Channel
        name: 'Detect Channel'
        description: 'Determines what channel this dataset is from. Switch statement handles the different file types if the mcaColumnToCheck variable is set.'
        type: 'Switch'
        dependsOn: [
          {
            activity: 'Set MCA Column'
            dependencyConditions: [
              'Succeeded'
            ]
          }
          {
            activity: 'Set Dataset Version'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          on: {
            value: '@if(empty(variables(\'mcaColumnToCheck\')), \'ignore\', last(array(split(activity(\'Read Manifest\').output.firstRow.blobs[0].blobName, \'.\'))))'
            type: 'Expression'
          }
          cases: [
            {
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
                      value: '@toLower(concat(variables(\'datasetType\'), \'_\', variables(\'datasetVersion\'), if(contains(activity(\'Check for MCA Column in CSV\').output.firstRow, variables(\'mcaColumnToCheck\')), \'_mca\', \'_ea\'), \'.json\'))'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
            {
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
                      value: '@toLower(concat(variables(\'datasetType\'), \'_\', variables(\'datasetVersion\'), if(contains(activity(\'Check for MCA Column in Gzip CSV\').output.firstRow, variables(\'mcaColumnToCheck\')), \'_mca\', \'_ea\'), \'.json\'))'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
            {
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
                      value: '@toLower(concat(variables(\'datasetType\'), \'_\', variables(\'datasetVersion\'), if(contains(activity(\'Check for MCA Column in Parquet\').output.firstRow, variables(\'mcaColumnToCheck\')), \'_mca\', \'_ea\'), \'.json\'))'
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
                  value: '@toLower(concat(variables(\'datasetType\'), \'_\', variables(\'datasetVersion\'), \'.json\'))'
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
            activity: 'Set Dataset Type'
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
            activity: 'Set Dataset Version'
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
            value: '@concat(\'The \', variables(\'schemaFile\'), \' schema mapping file was not found. Please confirm version \', variables(\'datasetVersion\'), \' of the \', variables(\'datasetType\'), \' dataset is supported by this version of FinOps hubs. You may need to upgrade to a newer release. To add support for another dataset, you can create a custom mapping file.\')'
            type: 'Expression'
          }
          errorCode: 'SchemaNotFound'
        }
      }
      { // For Each Blob
        name: 'For Each Blob'
        description: 'Loop thru each exported file listed in the manifest.'
        type: 'ForEach'
        dependsOn: [
          {
            activity: 'Check Schema'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          items: {
            value: '@activity(\'Read Manifest\').output.firstRow.blobs'
            type: 'Expression'
          }
          isSequential: false
          activities: [
            { // Execute
              name: 'Execute'
              description: 'Run the ETL pipeline.'
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
                    value: '@toLower(replace(concat(variables(\'datasetType\'),\'/\',substring(variables(\'date\'), 0, 4),\'/\',substring(variables(\'date\'), 4, 2),\'/\',variables(\'scope\')),\'//\',\'/\'))'
                    type: 'Expression'
                  }
                  destinationFile: {
                    value: '@concat(activity(\'Read Manifest\').output.firstRow.runInfo.runId, \'__\', last(array(split(replace(replace(item().blobName, \'.gz\', \'\'), \'.csv\', \'.parquet\'), \'/\'))))'
                    type: 'Expression'
                  }
                  keepFilePrefix: {
                    value: '@concat(activity(\'Read Manifest\').output.firstRow.runInfo.runId, \'__\')'
                    type: 'Expression'
                  }
                  schemaFile: {
                    value: '@variables(\'schemaFile\')'
                    type: 'Expression'
                  }
                }
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
      fileName: {
        type: 'string'
      }
    }
    variables: {
      datasetType: {
        type: 'String'
      }
      datasetVersion: {
        type: 'String'
      }
      date: {
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
    annotations: []
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
      { // Convert to Parquet
        name: 'Convert to Parquet'
        description: 'Convert CSV to parquet and move the file to the ${ingestionContainerName} container.'
        type: 'Switch'
        dependsOn: [
          {
            activity: 'Load Schema Mappings'
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
            {
              value: 'csv'
              activities: [
                {
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
                        type: 'Expression'
                        value: '@activity(\'Load Schema Mappings\').output.firstRow.additionalColumns'
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
                          value: '@concat(pipeline().parameters.destinationFolder, \'/\', pipeline().parameters.destinationFile)'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                }
              ]
            }
            {
              value: 'gz'
              activities: [
                {
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
                        type: 'Expression'
                        value: '@activity(\'Load Schema Mappings\').output.firstRow.additionalColumns'
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
                          value: '@concat(pipeline().parameters.destinationFolder, \'/\', pipeline().parameters.destinationFile)'
                          type: 'Expression'
                        }
                      }
                    }
                  ]
                }
              ]
            }
            {
              value: 'parquet'
              activities: [
                {
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
                          value: '@concat(pipeline().parameters.destinationFolder, \'/\', pipeline().parameters.destinationFile)'
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
            {
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
            value: '@and(endswith(item().name, \'.parquet\'), not(startswith(item().name, pipeline().parameters.keepFilePrefix)))'
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
      keepFilePrefix: {
        type: 'string'
      }
      schemaFile: {
        type: 'string'
      }
    }
    variables: {
      destinationFile: {
        type: 'String'
      }
    }
    annotations: []
  }
}

//------------------------------------------------------------------------------
// Start all triggers
//------------------------------------------------------------------------------

resource startTriggers 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${dataFactory.name}_startTriggers'
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  tags: union(tags, contains(tagsByResource, 'Microsoft.Resources/deploymentScripts') ? tagsByResource['Microsoft.Resources/deploymentScripts'] : {})
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    identityRoleAssignments
    trigger_FileAdded
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
