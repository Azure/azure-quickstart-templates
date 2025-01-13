// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Optional. Array of private endpoint connections. Pending ones will be approved.')
param privateEndpointConnections array = []

@description('Required. Name of the KeyVault.')
param keyVaultName string

//==============================================================================
// Resources
//==============================================================================

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource privateEndpointConnection 'Microsoft.KeyVault/vaults/privateEndpointConnections@2023-07-01' =  [ for privateEndpointConnection in privateEndpointConnections : if (privateEndpointConnection.properties.privateLinkServiceConnectionState.status == 'Pending') {
  name: last(array(split(privateEndpointConnection.id, '/')))
  parent: keyVault
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

output privateEndpointConnections array = keyVault.properties.privateEndpointConnections
