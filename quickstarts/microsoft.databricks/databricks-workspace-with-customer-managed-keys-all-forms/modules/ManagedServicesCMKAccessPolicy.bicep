@description('Name of the Key Vault that contains the CMK for managed services encryption ')
param msCmkKeyVaultName string

@description('The object id of AzureDatabricks application in your tenant. Application ID: 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d')
param azureDatabricksAppObjectId string

resource msCmkKeyVaultName_add 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: '${msCmkKeyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: azureDatabricksAppObjectId
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
