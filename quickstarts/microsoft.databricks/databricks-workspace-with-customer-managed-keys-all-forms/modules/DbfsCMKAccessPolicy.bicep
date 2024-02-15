param principalId string
param tenantId string

@description('Name of the Key Vault that contains the CMK used for DBFS encryption')
param dbfsCmkKeyVaultName string

resource dbfsCmkKeyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${dbfsCmkKeyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: principalId
        tenantId: tenantId
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
