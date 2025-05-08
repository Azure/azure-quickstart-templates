// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the publisher-specific Data Factory instance.')
param dataFactoryName string

@description('Required. Name of the Data Factory trigger to create or update.')
param triggerName string

// Storage details
@description('Optional. Azure storage container to monitor for updates and trigger events for.')
param storageAccountName string = ''
@description('Optional. Azure storage container to monitor for updates and trigger events for.')
param storageContainer string = ''
@description('Optional. Beginning of the storage path within the specified storageContainer to monitor for updates and trigger events for.')
param storagePathStartsWith string = ''
@description('Optional. End of the storage path to monitor for updates and trigger events for.')
param storagePathEndsWith string = ''

// Target pipeline details
@description('Required. Name of the Data Factory pipeline to execute when the trigger is executed.')
param pipelineName string
@description('Required. Parameters to pass to the pipeline when the trigger is executed.')
param pipelineParameters object
// @description('Required. Fully-qualified identifier of the event to publish.')
// param event string


//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Get references to existing resources
//------------------------------------------------------------------------------

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

//------------------------------------------------------------------------------
// Create trigger
//------------------------------------------------------------------------------

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource storageTrigger 'triggers' = if (!empty(storageAccountName)) {
    name: triggerName
    properties: {
      annotations: []
      pipelines: [
        {
          // TODO: Replace with apps_PublishEvent pipeline when event publishing is enabled
          pipelineReference: {
            referenceName: pipelineName
            type: 'PipelineReference'
          }
          parameters: pipelineParameters

          // pipelineReference: {
          //   referenceName: 'apps_PublishEvent'
          //   type: 'PipelineReference'
          // }
          // parameters: {
          //   event: event
          //   properties: '@triggerBody()'  // pass all trigger properties to the pipeline
          // }
        }
      ]
      type: 'BlobEventsTrigger'
      typeProperties: {
        blobPathBeginsWith: '/${storageContainer}/blobs/${storagePathStartsWith}'
        blobPathEndsWith: storagePathEndsWith
        ignoreEmptyBlobs: true
        scope: storageAccount.id
        events: [
          'Microsoft.Storage.BlobCreated'
        ]
      }
    }
  }
}


//==============================================================================
// Outputs
//==============================================================================

// @description('Fully-qualified event that is triggered when the configured event occurs.')
// output event string = event
