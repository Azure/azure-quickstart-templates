param workspace object

@description('Name of the Key Vault that contains the CMK used for DBFS encryption')
param dbfsCmkKeyVaultName string

resource dbfsCmkKeyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${dbfsCmkKeyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: workspace.storageAccountIdentity.principalId
        tenantId: workspace.storageAccountIdentity.tenantId
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
