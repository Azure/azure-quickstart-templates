// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { finOpsToolkitVersion, HubAppProperties, isSupportedVersion } from '../../fx/hub-types.bicep'
import { AppMetadata as CoreMetadata } from '../../Microsoft.FinOpsHubs/Core/metadata.bicep'
import { AppMetadata as ExportsMetadata } from '../Exports/metadata.bicep'
import { AppMetadata as ManagedExportsMetadata } from './metadata.bicep'

metadata hubApp = {
  id: 'Microsoft.CostManagement.ManagedExports'
  version: '15.0'
  dependencies: [
    'Microsoft.FinOpsHubs.Core'
    'Microsoft.CostManagement.Exports'
  ]
  metadata: 'https://microsoft.github.io/finops-toolkit/deploy/finops-hub/15.0/Microsoft.CostManagement/ManagedExports/metadata.bicep'
}


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app getting deployed.')
param app HubAppProperties

@description('Required. Metadata describing shared resources from the Core app. Must be v13 or higher.')
@validate(x => isSupportedVersion(x.version, '13.0', ''), 'Cost Management Managed Exports requires FinOps hubs version 13.0 or higher.')
param core CoreMetadata

@description('Required. Metadata describing shared resources from the Exports app. Must be v13 or higher.')
@validate(x => isSupportedVersion(x.version, '13.0', ''), 'Cost Management Managed Exports requires Cost Management Exports version 13.0 or higher.')
param exports ExportsMetadata


//==============================================================================
// Variables
//==============================================================================

var exportsApiVersion = '2023-07-01-preview'
var exportDataVersions = {
  focuscost: '1.2-preview'
  pricesheet: '2023-05-01'
  reservationdetails: '2023-03-01'
  reservationrecommendations: '2023-05-01'
  reservationtransactions: '2023-05-01'
}

// cSpell:ignore timeframe
// Function to generate the body for a Cost Management export
func getExportBody(exportContainerName string, datasetType string, schemaVersion string, isMonthly bool, exportFormat string, compressionMode string, partitionData string, dataOverwriteBehavior string) string => '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${schemaVersion}", "filters": [] }, "granularity": "Daily" }, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{variables(\'exportName\')}", "name": "@{variables(\'exportName\')}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }'

func getExportBodyV2(exportContainerName string, datasetType string, isMonthly bool, exportFormat string, compressionMode string, partitionData string, dataOverwriteBehavior string, recommendationScope string, recommendationLookbackPeriod string, resourceType string) string => /*
  */ toLower(datasetType) == 'focuscost' ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${exportDataVersions[toLower(datasetType)]}", "filters": [] }, "granularity": "Daily" }, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : toLower(datasetType) == 'reservationdetails' ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${exportDataVersions[toLower(datasetType)]}", "filters": [] }, "granularity": "Daily" }, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : (toLower(datasetType) == 'pricesheet') || (toLower(datasetType) == 'reservationtransactions') ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${exportDataVersions[toLower(datasetType)]}", "filters": [] }}, "timeframe": "${isMonthly ? 'TheCurrentMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-${toLower(datasetType)}\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : toLower(datasetType) == 'reservationrecommendations' ? /*
  */ '{ "properties": { "definition": { "dataSet": { "configuration": { "dataVersion": "${exportDataVersions[toLower(datasetType)]}", "filters": [ { "name": "reservationScope", "value": "${recommendationScope}" }, { "name": "resourceType", "value": "${resourceType}" }, { "name": "lookBackPeriod", "value": "${recommendationLookbackPeriod}" }] }}, "timeframe": "${isMonthly ? 'TheLastMonth': 'MonthToDate' }", "type": "${datasetType}" }, "deliveryInfo": { "destination": { "container": "${exportContainerName}", "rootFolderPath": "@{if(startswith(item().scope, \'/\'), substring(item().scope, 1, sub(length(item().scope), 1)) ,item().scope)}", "type": "AzureBlob", "resourceId": "@{variables(\'storageAccountId\')}" } }, "schedule": { "recurrence": "${ isMonthly ? 'Monthly' : 'Daily'}", "recurrencePeriod": { "from": "2024-01-01T00:00:00.000Z", "to": "2050-02-01T00:00:00.000Z" }, "status": "Inactive" }, "format": "${exportFormat}", "partitionData": "${partitionData}", "dataOverwriteBehavior": "${dataOverwriteBehavior}", "compressionMode": "${compressionMode}" }, "id": "@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "name": "@{toLower(concat(variables(\'finOpsHub\'), \'-${ isMonthly ? 'monthly' : 'daily'}-costdetails\'))}", "type": "Microsoft.CostManagement/reports", "identity": { "type": "systemAssigned" }, "location": "global" }' /*
  */ : 'undefined'

//==============================================================================
// Resources
//==============================================================================

// Register app
module appRegistration '../../fx/hub-app.bicep' = {
  name: 'Microsoft.CostManagement.ManagedExports_Register'
  params: {
    app: app
    version: finOpsToolkitVersion
    features: [
      'DataFactory'
    ]
    storageRoles: [
      // RBAC Administrator -- https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator
      // Used to create Cost Management exports (which require access to grant access)
      'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: app.storage
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: app.dataFactory

  resource dataset_config 'datasets' existing = {
    name: core.datasets.config
  }

  resource trigger_DailySchedule 'triggers' = {
    name: '${core.containers.config}_DailySchedule'
    properties: {
      pipelines: [
        {
          pipelineReference: {
            referenceName: dataFactory::pipeline_StartExportProcess.name
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
          // Data Factory requires a trailing 'Z' on startTime when timeZone resolves to 'UTC' (the
          // fallback for regions not in timeZones.bicep's map); a missing 'Z' fails trigger activation
          // with InvalidWorkflowTriggerRecurrence. Mapped, non-UTC regions must keep the no-'Z' format
          // so they continue scheduling on local wall-clock time.
          startTime: timeZones.outputs.Timezone == 'UTC' ? '2023-01-01T01:01:00Z' : '2023-01-01T01:01:00'
          timeZone: timeZones.outputs.Timezone
        }
      }
    }
  }

  resource trigger_MonthlySchedule 'triggers' = {
    name: '${core.containers.config}_MonthlySchedule'
    properties: {
      pipelines: [
        {
          pipelineReference: {
            referenceName: dataFactory::pipeline_StartExportProcess.name
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
          // See trigger_DailySchedule above for why the 'Z' suffix is conditional on the UTC fallback.
          startTime: timeZones.outputs.Timezone == 'UTC' ? '2023-01-05T01:11:00Z' : '2023-01-05T01:11:00'
          timeZone: timeZones.outputs.Timezone
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

  //----------------------------------------------------------------------------
  // config_StartBackfillProcess pipeline
  //----------------------------------------------------------------------------
  resource pipeline_StartBackfillProcess 'pipelines' = {
    name: '${core.containers.config}_StartBackfillProcess'
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
          defaultValue: app.hub.name
        }
        resourceManagementUri: {
          type: 'String'
          defaultValue: environment().resourceManager
        }
        fileName: {
          type: 'String'
          defaultValue: core.settings.file
        }
        folderPath: {
          type: 'String'
          defaultValue: core.containers.config
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

  //----------------------------------------------------------------------------
  // config_RunBackfillJob pipeline
  // Triggered by config_StartBackfillProcess pipeline
  //----------------------------------------------------------------------------
  resource pipeline_RunBackfillJob 'pipelines' = {
    name: '${core.containers.config}_RunBackfillJob'
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
                'Failed'
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
                    value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{variables(\'exportName\')}/run?api-version=${exportsApiVersion}'
                    type: 'Expression'
                  }
                  method: 'POST'
                  headers: {
                    'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunBackfill@${finOpsToolkitVersion}'
                    'Content-Type': 'application/json'
                    ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
          defaultValue: app.hub.name
        }
        resourceManagementUri: {
          type: 'String'
          defaultValue: environment().resourceManager
        }
        fileName: {
          type: 'String'
          defaultValue: core.settings.file
        }
        folderPath: {
          type: 'String'
          defaultValue: core.containers.config
        }
        scopesArray: {
          type: 'Array'
        }
      }
    }
  }

  //----------------------------------------------------------------------------
  // config_StartExportProcess pipeline
  // Triggered by config_DailySchedule/MonthlySchedule triggers
  //----------------------------------------------------------------------------
  resource pipeline_StartExportProcess 'pipelines' = {
    name: '${core.containers.config}_StartExportProcess'
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
                'Failed'
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
                    value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports?api-version=${exportsApiVersion}'
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
          defaultValue: core.settings.file
        }
        folderPath: {
          type: 'String'
          defaultValue: core.containers.config
        }
        finOpsHub: {
          type: 'String'
          defaultValue: app.hub.name
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

  //----------------------------------------------------------------------------
  // config_RunExportJobs pipeline
  // Triggered by pipeline_StartExportProcess pipeline
  //----------------------------------------------------------------------------
  resource pipeline_RunExportJobs 'pipelines' = {
    name: '${core.containers.config}_RunExportJobs'
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
                          value: '@{replace(toLower(concat(variables(\'resourceManagementUri\'),item().id)), \'com//\', \'com/\')}/run?api-version=${exportsApiVersion}'
                          type: 'Expression'
                        }
                        headers: {
                          'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs@${finOpsToolkitVersion}'
                          ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
          defaultValue: app.hub.name
        }
      }
    }
  }

  //----------------------------------------------------------------------------
  // config_ConfigureExports pipeline
  // Triggered by config_SettingsUpdated trigger
  //----------------------------------------------------------------------------
  resource pipeline_ConfigureExports 'pipelines' = {
    name: '${core.containers.config}_ConfigureExports'
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
                'Failed'
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
                    // Detect scope type: mca (has colon), ea-department (has /departments/), ea (billing account), subscription, or undefined
                    value: '@if(contains(toLower(item().scope), \'providers/microsoft.billing/billingaccounts\'), if(contains(toLower(item().scope), \':\'), \'mca\', if(contains(toLower(item().scope), \'/departments/\'), \'ea-department\', \'ea\')), if(contains(toLower(item().scope), \'subscriptions/\'), \'subscription\', \'undefined\'))'
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
                        { // 'Open month focus export'
                          name: 'Open month focus export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-costdetails\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'FocusCost', false, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsDaily@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                        { // 'Closed month focus export'
                          name: 'Closed month focus export'
                          type: 'WebActivity'
                          dependsOn: [
                            {
                              activity: 'Open month focus export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-costdetails\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'FocusCost', true, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsMonthly@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                        { // 'Monthly pricesheet export'
                          name: 'Monthly pricesheet export'
                          type: 'WebActivity'
                          dependsOn: [
                            {
                              activity: 'Closed month focus export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-pricesheet\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'Pricesheet', true, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.Prices@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                              activity: 'Monthly pricesheet export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-pricesheet\'))}/run?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.Prices@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                        { // 'Daily reservation details export'
                          name: 'Daily reservation details export'
                          type: 'WebActivity'
                          dependsOn: [
                            {
                              activity: 'Monthly pricesheet export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-reservationdetails\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'ReservationDetails', false, 'CSV', 'None', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.ReservationDetails@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                        { // 'Daily reservation transactions export'
                          name: 'Daily reservation transactions export'
                          type: 'WebActivity'
                          dependsOn: [
                            {
                              activity: 'Daily reservation details export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-reservationtransactions\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'ReservationTransactions', false, 'CSV', 'None', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.ReservationTransactions@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                        { // 'Daily recommendations shared last30day virtual machines export'
                          name: 'Daily shared 30day virtual machines'
                          type: 'WebActivity'
                          dependsOn: [
                            {
                              activity: 'Daily reservation transactions export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-recommendations-shared-last30days-virtualmachines\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'ReservationRecommendations', false, 'CSV', 'None', 'true', 'CreateNewReport', 'Shared', 'Last30Days', 'VirtualMachines')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.ReservationRecommendations.VM.Shared.30d@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                    { // EA Department - only cost details are supported at department scope (no pricesheet, reservation details/transactions, or recommendations)
                      value: 'ea-department'
                      activities: [
                        { // 'EA Department open month focus export'
                          name: 'EA Department open month focus export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-costdetails\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'FocusCost', false, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsDaily@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                        { // 'EA Department closed month focus export'
                          name: 'EA Department closed month focus export'
                          type: 'WebActivity'
                          dependsOn: [
                            {
                              activity: 'EA Department open month focus export'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-costdetails\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'FocusCost', true, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsMonthly@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-daily-costdetails\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'FocusCost', false, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsDaily@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
                              value: '@{variables(\'resourceManagementUri\')}@{item().scope}/providers/Microsoft.CostManagement/exports/@{toLower(concat(variables(\'finOpsHub\'), \'-monthly-costdetails\'))}?api-version=${exportsApiVersion}'
                              type: 'Expression'
                            }
                            method: 'PUT'
                            body: {
                              value: getExportBodyV2(exports.containers.msexports, 'FocusCost', true, 'Parquet', 'Snappy', 'true', 'CreateNewReport', '', '', '')
                              type: 'Expression'
                            }
                            headers: {
                              'x-ms-command-name': 'FinOpsToolkit.Hubs.config_RunExportJobs.CostsMonthly@${finOpsToolkitVersion}'
                              ClientType: 'FinOpsToolkit.Hubs@${finOpsToolkitVersion}'
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
          defaultValue: app.hub.name
        }
        resourceManagementUri: {
          type: 'String'
          defaultValue: environment().resourceManager
        }
        fileName: {
          type: 'String'
          defaultValue: core.settings.file
        }
        folderPath: {
          type: 'String'
          defaultValue: core.containers.config
        }
      }
    }
  }
}

// TODO: Can we move this into hub-types.bicep or merge it here?
module timeZones 'timeZones.bicep' = {
  name: 'Microsoft.CostManagement.ManagedExports_TimeZones'
  params: {
    location: app.hub.location
  }
}

module trigger_SettingsUpdated '../../fx/hub-eventTrigger.bicep' = {
  name: 'Microsoft.FinOpsHubs.Core_SettingsUpdatedTrigger'
  params: {
    dataFactoryName: dataFactory.name
    triggerName: '${core.containers.config}_SettingsUpdated'

    // TODO: Replace pipeline with event: 'Microsoft.FinOpsHubs.Core.SettingsUpdated'
    pipelineName: dataFactory::pipeline_ConfigureExports.name
    pipelineParameters: {}
    
    storageAccountName: app.storage
    storageContainer: core.containers.config
    // TODO: Change this to startswith
    storagePathEndsWith: core.settings.file
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('Metadata describing resources created by the Cost Management Managed Exports app.')
output metadata ManagedExportsMetadata = {
  id: 'Microsoft.CostManagement.ManagedExports'
  version: finOpsToolkitVersion
  pipelines: {
    configureExports: dataFactory::pipeline_ConfigureExports.name
    startBackfillProcess: dataFactory::pipeline_StartBackfillProcess.name
    startExportProcess: dataFactory::pipeline_StartExportProcess.name
  }
}
