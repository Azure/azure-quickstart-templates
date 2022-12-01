param workspace object

@description('The Azure Key Vault name.')
param keyVaultName string

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: workspace.properties.storageAccountIdentity.principalId
        tenantId: workspace.properties.storageAccountIdentity.tenantId
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
