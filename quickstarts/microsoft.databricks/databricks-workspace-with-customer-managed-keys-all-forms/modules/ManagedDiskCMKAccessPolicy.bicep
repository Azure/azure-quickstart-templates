param workspaceManagedDiskIdentity object

@description('Name of the Key Vault that contains the CMK used for managed disks encryption')
param diskCmkKeyVaultName string

resource diskCmkKeyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${diskCmkKeyVaultName}/add'
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
