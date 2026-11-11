// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { HubAppProperties } from 'hub-types.bicep'


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app getting deployed.')
param app HubAppProperties

@description('Required. List of Azure Data Factory instances to start triggers for. Can be up to 1 per publisher.')
param dataFactoryInstances string[]

@description('Required. Name of the managed identity to use when starting the triggers.')
param identityName string

@description('Optional. Start all triggers for the Data Factory instances. Default: false.')
param startAllTriggers bool = false

@description('Optional. List of pipelines to run. Default: [] (no pipelines).')
param startPipelines string[] = []


//==============================================================================
// Variables
//==============================================================================

// Clean up dataFactoryInstances array - remove empty values and duplicates
var uniqueInstances = union(filter(dataFactoryInstances, adf => !empty(adf)), [])

//==============================================================================
// Resources
//==============================================================================

// Initialize Data Factory instances (start triggers and/or run pipelines)
module initialize 'hub-deploymentScript.bicep' = [
  for adf in uniqueInstances: {
    name: length('Microsoft.FinOpsHubs.Init_${adf}') <= 64 ? 'Microsoft.FinOpsHubs.Init_${adf}' : substring('Microsoft.FinOpsHubs.Init_${adf}', 0, 64)
    params: {
      app: app
      identityName: identityName
      scriptContent: loadTextContent('./scripts/Init-DataFactory.ps1')
      arguments: join(filter([
        '-DataFactoryResourceGroup "${resourceGroup().name}"'
        '-DataFactoryName "${adf}"'
        !empty(startPipelines) ? '-Pipelines "${join(startPipelines, '|')}"' : ''
        startAllTriggers ? '-StartTriggers' : ''
      ], arg => !empty(arg)), ' ')
    }
  }
]

//==============================================================================
// Outputs
//==============================================================================

// None
