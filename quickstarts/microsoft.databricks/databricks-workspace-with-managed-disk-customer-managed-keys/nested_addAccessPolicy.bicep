param workspace object

@description('The key vault name used for BYOK')
param keyVaultName string

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: workspace.managedDiskIdentity.principalId
        tenantId: workspace.managedDiskIdentity.tenantId
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
