// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { finOpsToolkitVersion, HubAppProperties, isSupportedVersion } from '../../fx/hub-types.bicep'
import { AppMetadata as CoreMetadata } from '../Core/metadata.bicep'
import { AppMetadata as AzureResourceGraphMetadata } from './metadata.bicep'

metadata hubApp = {
  id: 'Microsoft.FinOpsHubs.AzureResourceGraph'
  version: '15.0'
  dependencies: [
    'Microsoft.FinOpsHubs.Core'
    'Microsoft.FinOpsHubs.IngestionQueries'
  ]
  metadata: 'https://microsoft.github.io/finops-toolkit/deploy/finops-hub/15.0/Microsoft.FinOpsHubs/AzureResourceGraph/metadata.bicep'
}


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app getting deployed.')
param app HubAppProperties

@description('Required. Metadata describing shared resources from the Core app. Must be v13 or higher.')
@validate(x => isSupportedVersion(x.version, '13.0', ''), 'Core app version must be 13.0 or higher.')
param core CoreMetadata



//==============================================================================
// Variables
//==============================================================================



//==============================================================================
// Resources
//==============================================================================

// Register app
module appRegistration '../../fx/hub-app.bicep' = {
  name: 'Microsoft.FinOpsHubs.AzureResourceGraph_Register'
  params: {
    app: app
    version: finOpsToolkitVersion
    features: [
      'DataFactory'  // ARG dataset and engine pipeline
    ]
  }
}

// Get data factory instance
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: app.dataFactory
  dependsOn: [appRegistration]
}

//------------------------------------------------------------------------------
// Datasets
//------------------------------------------------------------------------------

// Reference the ARM linked service (created by the Core app)
resource linkedService_arm 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' existing = {
  name: core.linkedServices.azurerm
  parent: dataFactory
}

// Resource Graph dataset - points to the ARG REST API
resource dataset_azureResourceGraph 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'azureResourceGraph'
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {}
    type: 'RestResource'
    typeProperties: {
      relativeUrl: '/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01'
    }
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_arm.name
      type: 'LinkedServiceReference'
    }
  }
}

// Reference existing ingestion dataset from Core app
resource dataset_ingestion 'Microsoft.DataFactory/factories/datasets@2018-06-01' existing = {
  name: core.datasets.ingestion
  parent: dataFactory
}

//------------------------------------------------------------------------------
// Engine pipeline
//------------------------------------------------------------------------------

resource pipeline_ExecuteQuery 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'queries_ResourceGraph_ExecuteQuery'
  parent: dataFactory
  properties: {
    activities: [
      {
        name: 'Check Query Has Results'
        description: 'Run the query with | count to check if there are any results before attempting the full copy.'
        type: 'WebActivity'
        dependsOn: []
        policy: {
          timeout: '0.00:05:00'
          retry: 1
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          url: '${environment().resourceManager}providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01'
          method: 'POST'
          headers: {
            'Content-Type': 'application/json'
          }
          body: {
            value: '@concat(\'{ "query": "\', pipeline().parameters.query, \' | count" }\')'
            type: 'Expression'
          }
          authentication: {
            type: 'MSI'
            resource: environment().resourceManager
          }
        }
      }
      {
        name: 'If Query Has Results'
        description: 'Only run the copy if the query returned results to avoid schema mapping errors on empty result sets.'
        type: 'IfCondition'
        dependsOn: [
          {
            activity: 'Check Query Has Results'
            dependencyConditions: ['Succeeded']
          }
        ]
        userProperties: []
        typeProperties: {
          expression: {
            value: '@greater(int(activity(\'Check Query Has Results\').output.data[0].Count), 0)'
            type: 'Expression'
          }
          ifTrueActivities: [
            {
              name: 'Execute ARG Query'
              description: 'Execute a single ARG query and write the result to the ingestion container as Parquet.'
              type: 'Copy'
              dependsOn: []
              policy: {
                timeout: '0.00:10:00'
                retry: 0
                retryIntervalInSeconds: 60
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                source: {
                  type: 'RestSource'
                  httpRequestTimeout: '00:02:00'
                  requestInterval: '00.00:00:00.050'
                  requestMethod: 'POST'
                  // Query text is from trusted config/queries/*.json files; no escaping needed.
                  requestBody: {
                    value: '@concat(\'{ "query": "\', pipeline().parameters.query, \' | extend x_SourceName=\\"\', pipeline().parameters.querySource, \'\\", x_SourceType=\\"\', pipeline().parameters.queryType, \'\\", x_SourceProvider=\\"\', pipeline().parameters.queryProvider, \'\\", x_SourceVersion=\\"\', pipeline().parameters.queryVersion, \'\\"" }\')'
                    type: 'Expression'
                  }
                  additionalHeaders: {
                    'Content-Type': 'application/json'
                  }
                }
                sink: {
                  type: 'ParquetSink'
                  storeSettings: {
                    type: 'AzureBlobFSWriteSettings'
                  }
                  formatSettings: {
                    type: 'ParquetWriteSettings'
                  }
                }
                enableStaging: false
                translator: {
                  value: '@pipeline().parameters.translator'
                  type: 'Expression'
                }
              }
              inputs: [
                {
                  referenceName: dataset_azureResourceGraph.name
                  type: 'DatasetReference'
                  parameters: {}
                }
              ]
              outputs: [
                {
                  referenceName: dataset_ingestion.name
                  type: 'DatasetReference'
                  parameters: {
                    blobPath: {
                      value: '@pipeline().parameters.ingestionPath'
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
      query: {
        type: 'String'
      }
      querySource: {
        type: 'String'
      }
      queryType: {
        type: 'String'
      }
      queryProvider: {
        type: 'String'
      }
      queryVersion: {
        type: 'String'
      }
      ingestionPath: {
        type: 'String'
      }
      translator: {
        type: 'Object'
      }
    }
    policy: {
      elapsedTimeMetric: {}
    }
    annotations: []
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('The app properties for the AzureResourceGraph app.')
output app HubAppProperties = app

@description('Metadata describing resources created by the AzureResourceGraph app.')
output metadata AzureResourceGraphMetadata = {
  id: 'Microsoft.FinOpsHubs.AzureResourceGraph'
  version: finOpsToolkitVersion
  datasets: {
    azureResourceGraph: dataset_azureResourceGraph.name
  }
}
