@description('The key vault name used for customer-managed key for managed services')
param keyVaultName string

@description('The object ID of the AzureDatabricks enterprise application.')
param ObjectID string

resource keyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2022-11-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: ObjectID
        tenantId: subscription().tenantId
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
