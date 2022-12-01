param workspace object

@description('The key vault name used for BYOK')
param keyVaultName string

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: workspace.properties.managedDiskIdentity.principalId
        tenantId: workspace.properteis.managedDiskIdentity.tenantId
        permissions: {
          keys: [
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
  }
}
