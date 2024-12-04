// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Optional. Array of private endpoint connections. Pending ones will be approved.')
param privateEndpointConnections array = []

@description('Required. Name of the ADX cluster.')
param dataExplorerName string

//==============================================================================
// Resources
//==============================================================================

resource cluster 'Microsoft.Kusto/clusters@2023-08-15' existing = {
  name: dataExplorerName
}

resource privateEndpointConnection 'Microsoft.Kusto/clusters/privateEndpointConnections@2023-08-15' =  [ for privateEndpointConnection in privateEndpointConnections : if (privateEndpointConnection.properties.privateLinkServiceConnectionState.status == 'Pending') {
  name: last(array(split(privateEndpointConnection.id, '/')))
  parent: cluster
  properties: {
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Approved-by-pipeline'
    }
  }
}]

//==============================================================================
// Outputs
//==============================================================================

output privateEndpointConnections array = cluster.properties.privateEndpointConnections
