param vaultName string = 'keyVault${uniqueString(resourceGroup().id)}' // must be globally unique
param location string = resourceGroup().location
param sku string = 'Standard'
param tenant string = '72f988bf-86f1-41af-91ab-2d7cd011db47' // replace with your tenantId
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: 'caeebed6-cfa8-45ff-9d8a-03dba4ef9a7d' // replace with your objectId
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
    }
  }
]

param enabledForDeployment bool = true
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enableRbacAuthorization bool = false
param softDeleteRetentionInDays int = 90

param keyName string = 'prodKey'
param secretName string = 'bankAccountPassword'
param secretValue string = '12345'

param networkAcls object = {
  ipRules: []
  virtualNetworkRules: []
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: tenant
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    networkAcls: networkAcls
  }
}

// create key
resource key 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  name: '${keyvault.name}/${keyName}'
  properties: {
    kty: 'RSA' // key type
    keyOps: [
      // key operations
      'encrypt'
      'decrypt'
    ]
    keySize: 4096
  }
}

// create secret
resource secret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName}'
  properties: {
    value: secretValue
  }
}

output proxyKey object = key
