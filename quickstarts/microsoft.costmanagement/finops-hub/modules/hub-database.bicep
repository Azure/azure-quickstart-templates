// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the FinOps hub Data Explorer instance.')
param clusterName string

@description('Required. Name of the FinOps hub Data Explorer database to create or update.')
param databaseName string

@description('Required. List of database scripts to run. The key is the name of the database script and the value is the KQL script content.')
param scripts object

@description('Optional. If true, ingestion will continue even if some rows fail to ingest. Default: false.')
param continueOnErrors bool = false

@description('Optional. Forces the table to be updated if different from the last time it was deployed.')
param forceUpdateTag string = utcNow()


//==============================================================================
// Resources
//==============================================================================

resource cluster 'Microsoft.Kusto/clusters@2023-08-15' existing = {
  name: clusterName

  resource database 'databases' existing = {
    name: databaseName

    resource script 'scripts' = [for scr in items(scripts) : {
      name: scr.key
      properties: {
        scriptContent: scr.value
        continueOnErrors: continueOnErrors
        forceUpdateTag: forceUpdateTag
      }
    }]
  }
}


//==============================================================================
// Outputs
//==============================================================================

// TODO
