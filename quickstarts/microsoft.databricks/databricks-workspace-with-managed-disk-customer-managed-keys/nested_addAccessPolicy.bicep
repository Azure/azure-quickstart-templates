param workspaceManagedDiskIdentity object

@description('The key vault name used for BYOK')
param keyVaultName string

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: workspaceManagedDiskIdentity.principalId
        tenantId: workspaceManagedDiskIdentity.tenantId
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
