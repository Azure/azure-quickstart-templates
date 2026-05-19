@description('The name of the key vault to be created.')
param vaultName string

@description('The name of the key to be created.')
param keyName string

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The SKU of the vault to be created.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('The JsonWebKeyType of the key to be created.')
@allowed([
  'EC'
  'EC-HSM'
  'RSA'
  'RSA-HSM'
])
param keyType string = 'RSA'

@description('The permitted JSON web key operations of the key to be created.')
param keyOps array = []

@description('The size in bits of the key to be created.')
param keySize int = 2048

@description('The JsonWebKeyCurveName of the key to be created.')
@allowed([
  ''
  'P-256'
  'P-256K'
  'P-384'
  'P-521'
])
param curveName string = ''

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2023-07-01' = {
  parent: vault
  name: keyName
  properties: {
    kty: keyType
    keyOps: keyOps
    keySize: keySize
    curveName: curveName
  }
}

output proxyKey object = key.properties
output location string = location
output name string = vault.name
output resourceGroupName string = resourceGroup().name
output resourceId string = vault.id
