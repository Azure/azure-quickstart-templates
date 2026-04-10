param principalId string
param tenantId string

@description('Name of the Key Vault that contains the CMK used for managed disks encryption')
param diskCmkKeyVaultName string

resource diskCmkKeyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${diskCmkKeyVaultName}/add'
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
