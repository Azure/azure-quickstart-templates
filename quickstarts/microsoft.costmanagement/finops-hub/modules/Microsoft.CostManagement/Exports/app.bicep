// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { finOpsToolkitVersion, HubAppProperties, isSupportedVersion } from '../../fx/hub-types.bicep'
import { AppMetadata as CoreMetadata } from '../../Microsoft.FinOpsHubs/Core/metadata.bicep'
import { AppMetadata as ExportsMetadata } from './metadata.bicep'

metadata hubApp = {
  id: 'Microsoft.CostManagement.Exports'
  version: '15.0'
  dependencies: [
    'Microsoft.FinOpsHubs.Core'
  ]
  metadata: 'https://microsoft.github.io/finops-toolkit/deploy/finops-hub/15.0/Microsoft.CostManagement/Exports/metadata.bicep'
}


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app getting deployed.')
param app HubAppProperties

@description('Required. Metadata describing shared resources from the Core app. Must be v13 or higher.')
@validate(x => isSupportedVersion(x.version, '13.0', ''), 'Cost Management Exports requires FinOps hubs version 13.0 or higher.')
param core CoreMetadata


//==============================================================================
// Variables
//==============================================================================

var MSEXPORTS = 'msexports'


//==============================================================================
// Resources
//==============================================================================

// Register app
module appRegistration '../../fx/hub-app.bicep' = {
  name: 'Microsoft.CostManagement.Exports_Register'
  params: {
    app: app
    version: finOpsToolkitVersion
    features: [
      'Storage'      // msexports + schema files
      'DataFactory'  // Move files from msexports to ingestion
    ]
  }
}

//------------------------------------------------------------------------------
// Storage
//------------------------------------------------------------------------------

// Upload schema files
module schemaFiles '../../fx/hub-storage.bicep' = {
  name: 'Microsoft.CostManagement.Exports_Storage.SchemaFiles'
  dependsOn: [
    appRegistration
  ]
  params: {
    app: app
    container: core.containers.config
    files: {
      // cSpell:ignore actualcost, amortizedcost, focuscost, pricesheet, reservationdetails, reservationrecommendations, reservationtransactions
      'schemas/actualcost_c360-2025-04.json': loadTextContent('./schemas/actualcost_c360-2025-04.json')
      'schemas/amortizedcost_c360-2025-04.json': loadTextContent('./schemas/amortizedcost_c360-2025-04.json')
      'schemas/focuscost_1.2.json': loadTextContent('./schemas/focuscost_1.2.json')
      'schemas/focuscost_1.2-preview.json': loadTextContent('./schemas/focuscost_1.2-preview.json')
      'schemas/focuscost_1.0r2.json': loadTextContent('./schemas/focuscost_1.0r2.json')
      'schemas/focuscost_1.0.json': loadTextContent('./schemas/focuscost_1.0.json')
      'schemas/focuscost_1.0-preview(v1).json': loadTextContent('./schemas/focuscost_1.0-preview(v1).json')
      'schemas/pricesheet_2023-05-01_ea.json': loadTextContent('./schemas/pricesheet_2023-05-01_ea.json')
      'schemas/pricesheet_2023-05-01_mca.json': loadTextContent('./schemas/pricesheet_2023-05-01_mca.json')
      'schemas/reservationdetails_2023-03-01.json': loadTextContent('./schemas/reservationdetails_2023-03-01.json')
      'schemas/reservationrecommendations_2023-05-01_ea.json': loadTextContent('./schemas/reservationrecommendations_2023-05-01_ea.json')
      'schemas/reservationrecommendations_2023-05-01_mca.json': loadTextContent('./schemas/reservationrecommendations_2023-05-01_mca.json')
      'schemas/reservationtransactions_2023-05-01_ea.json': loadTextContent('./schemas/reservationtransactions_2023-05-01_ea.json')
      'schemas/reservationtransactions_2023-05-01_mca.json': loadTextContent('./schemas/reservationtransactions_2023-05-01_mca.json')
    }
  }
}

// Create msexports container
module exportContainer '../../fx/hub-storage.bicep' = {
  name: 'Microsoft.CostManagement.Exports_Storage.ExportContainer'
  dependsOn: [
    appRegistration
  ]
  params: {
    app: app
    container: MSEXPORTS
  }
}

//------------------------------------------------------------------------------
// Data Factory
//------------------------------------------------------------------------------

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: app.dataFactory
  dependsOn: [
    appRegistration
  ]
  
  // cSpell:ignore linkedservices
  resource linkedService_storageAccount 'linkedservices' existing = {
    name: app.storage
  }

  resource dataset_config 'datasets' existing = {
    name: core.datasets.config
  }

  resource dataset_ingestion 'datasets' existing = {
    name: core.datasets.ingestion
  }

  resource dataset_ingestion_files 'datasets' existing = {
    name: core.datasets.ingestionFiles
  }

  resource dataset_ingestion_manifest 'datasets' existing = {
    name: core.datasets.ingestionManifest
  }

  resource dataset_msexports_manifest 'datasets' = {
    name: '${MSEXPORTS}_manifest'
    properties: {
      parameters: {
        fileName: {
          type: 'String'
          defaultValue: 'manifest.json'
        }
        folderPath: {
          type: 'String'
          defaultValue: MSEXPORTS
        }
      }
      type: 'Json'
      typeProperties: {
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
      linkedServiceName: {
        referenceName: app.storage
        type: 'LinkedServiceReference'
      }
    }
  }

  resource dataset_msexports 'datasets' = {
    name: replace(MSEXPORTS, '-', '_')
    properties: {
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
          fileSystem: MSEXPORTS
        }
        columnDelimiter: ','
        escapeChar: '"'
        quoteChar: '"'
        firstRowAsHeader: true
      }
      linkedServiceName: {
        referenceName: linkedService_storageAccount.name
        type: 'LinkedServiceReference'
      }
    }
  }

  resource dataset_msexports_gzip 'datasets' = {
    name: '${MSEXPORTS}_gzip'
    properties: {
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
          fileSystem: MSEXPORTS
        }
        columnDelimiter: ','
        escapeChar: '"'
        quoteChar: '"'
        firstRowAsHeader: true
        compressionCodec: 'Gzip'
      }
      linkedServiceName: {
        referenceName: linkedService_storageAccount.name
        type: 'LinkedServiceReference'
      }
    }
  }

  resource dataset_msexports_parquet 'datasets' = {
    name: '${MSEXPORTS}_parquet'
    properties: {
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
          fileSystem: MSEXPORTS
        }
      }
      linkedServiceName: {
        referenceName: linkedService_storageAccount.name
        type: 'LinkedServiceReference'
      }
    }
  }

  //---------------------------------------------------------------------------
  // msexports_ExecuteETL pipeline
  // Triggered by msexports_ManifestAdded trigger
  //---------------------------------------------------------------------------
  resource pipeline_ExecuteExportsETL 'pipelines' = {
    name: '${MSEXPORTS}_ExecuteETL'
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
              referenceName: dataFactory::dataset_msexports_manifest.name
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
          description: 'Check if there are no blobs or no data rows in the export.'
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
              value: '@or(equals(activity(\'Read Manifest\').output.firstRow.blobCount, null), equals(activity(\'Read Manifest\').output.firstRow.blobCount, 0), and(contains(activity(\'Read Manifest\').output.firstRow, \'dataRowCount\'), or(equals(activity(\'Read Manifest\').output.firstRow.dataRowCount, null), equals(activity(\'Read Manifest\').output.firstRow.dataRowCount, 0))))'
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
                        referenceName: dataFactory::dataset_msexports.name
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
                        referenceName: dataFactory::dataset_msexports_gzip.name
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
                        referenceName: dataFactory::dataset_msexports_parquet.name
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
              referenceName: dataFactory::dataset_config.name
              type: 'DatasetReference'
              parameters: {
                fileName: {
                  value: '@variables(\'schemaFile\')'
                  type: 'Expression'
                }
                folderPath: '${schemaFiles.outputs.containerName}/schemas'
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
            batchCount: app.hub.options.privateRouting ? 4 : 30 // so we don't overload the managed runtime
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
          description: 'Copy the manifest to the ingestion container to trigger ADX ingestion. Skipped when there are no data rows to avoid triggering downstream ingestion with no parquet files.'
          type: 'IfCondition'
          dependsOn: [
            {
              activity: 'For Each Blob'
              dependencyConditions: [
                'Succeeded'
              ]
            }
          ]
          userProperties: []
          typeProperties: {
            expression: {
              value: '@not(variables(\'hasNoRows\'))'
              type: 'Expression'
            }
            ifTrueActivities: [
              {
                name: 'Copy Manifest to Ingestion'
                description: 'Copy the manifest to the ingestion container to trigger ADX ingestion.'
                type: 'Copy'
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
                    referenceName: dataFactory::dataset_msexports_manifest.name
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
                    referenceName: dataFactory::dataset_ingestion_manifest.name
                    type: 'DatasetReference'
                    parameters: {
                      fileName: 'manifest.json'
                      folderPath: {
                        value: '@concat(\'${core.containers.ingestion}/\', variables(\'destinationFolder\'))'
                        type: 'Expression'
                      }
                    }
                  }
                ]
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

  //---------------------------------------------------------------------------
  // msexports_ETL_ingestion pipeline
  // Triggered by msexports_ExecuteETL
  //---------------------------------------------------------------------------
  resource pipeline_ToIngestion 'pipelines' = {
    name: '${MSEXPORTS}_ETL_${core.containers.ingestion}'
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
              referenceName: dataFactory::dataset_ingestion_files.name
              type: 'DatasetReference'
              parameters: {
                folderPath: '@pipeline().parameters.destinationFolder'
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
        { // Filter Out Current Exports
          name: 'Filter Out Current Exports'
          description: 'Remove existing files from the current export so those files do not get deleted.'
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
              // cSpell:ignore endswith
              value: '@and(endswith(item().name, \'.parquet\'), not(startswith(item().name, concat(pipeline().parameters.ingestionId, \'${core.ingestionIdFileNameSeparator}\'))))'
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
              referenceName: dataFactory::dataset_config.name
              type: 'DatasetReference'
              parameters: {
                fileName: {
                  value: '@toLower(pipeline().parameters.schemaFile)'
                  type: 'Expression'
                }
                folderPath: '${core.containers.config}/schemas'
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
                    referenceName: dataFactory::dataset_ingestion.name
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
              value: '@concat(pipeline().parameters.destinationFolder, \'/\', pipeline().parameters.ingestionId, \'${core.ingestionIdFileNameSeparator}\', pipeline().parameters.destinationFile)'
              type: 'Expression'
            }
          }
        }
        { // Convert to Parquet
          name: 'Convert to Parquet'
          description: 'Convert CSV to parquet and move the file to the ${core.containers.ingestion} container.'
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
                        referenceName: dataFactory::dataset_msexports.name
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
                        referenceName: dataFactory::dataset_ingestion.name
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
                        referenceName: dataFactory::dataset_msexports_gzip.name
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
                        referenceName: dataFactory::dataset_ingestion.name
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
                        referenceName: dataFactory::dataset_msexports_parquet.name
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
                        referenceName: dataFactory::dataset_ingestion.name
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
              referenceName: dataFactory::dataset_config.name
              type: 'DatasetReference'
              parameters: {
                fileName: core.settings.file
                folderPath: core.containers.config
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
                    referenceName: dataFactory::dataset_msexports_parquet.name
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
    }
  }
}

// msexports_ManifestAdded trigger -> msexports_ExecuteETL pipeline
module trigger_ExportManifestAdded '../../fx/hub-eventTrigger.bicep' = {
  name: 'Microsoft.CostManagement.Exports_ADF.ExportManifestTrigger'
  params: {
    dataFactoryName: dataFactory.name
    triggerName: '${MSEXPORTS}_ManifestAdded'

    // TODO: Replace pipeline with event: 'Microsoft.CostManagement.Exports.ManifestAdded'
    pipelineName: dataFactory::pipeline_ExecuteExportsETL.name
    pipelineParameters: {
      folderPath: '@triggerBody().folderPath'
      fileName: '@triggerBody().fileName'
    }
    
    storageAccountName: app.storage
    storageContainer: MSEXPORTS
    storagePathEndsWith: 'manifest.json'
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('Properties of the hub app.')
output app HubAppProperties = app

@description('Number of schema files uploaded.')
output schemaFilesUploaded int = schemaFiles.outputs.filesUploaded

@description('Metadata describing resources created by the Cost Management Exports app.')
output metadata ExportsMetadata = {
  id: 'Microsoft.CostManagement.Exports'
  version: finOpsToolkitVersion
  containers: {
    msexports: exportContainer.outputs.containerName
  }
  datasets: {
    msexportsManifest: dataFactory::dataset_msexports_manifest.name
    msexports: dataFactory::dataset_msexports.name
    msexportsGzip: dataFactory::dataset_msexports_gzip.name
    msexportsParquet: dataFactory::dataset_msexports_parquet.name
  }
}
