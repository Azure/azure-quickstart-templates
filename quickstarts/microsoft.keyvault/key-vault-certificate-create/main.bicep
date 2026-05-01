@description('The name of the key vault to be created.')
param vaultName string

@description('The name of the certificate to be created.')
param certificateName string

@description('The location of the resources.')
param location string = resourceGroup().location

@description('The SKU of the vault to be created.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('The common name (subject) for the self-signed certificate. Defaults to the certificate name.')
param certificateCommonName string = certificateName

@description('The validity of the certificate in months.')
@minValue(1)
@maxValue(1200)
param validityInMonths int = 12

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
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

// Key Vault certificates are a data-plane concept and cannot be created
// directly through ARM. Use the public Bicep registry module which wraps
// `az keyvault certificate create` in a deployment script (it provisions a
// user-assigned managed identity with the Key Vault Certificate Officer
// role on the vault for the duration of the deployment).
module certificate 'br/public:deployment-scripts/create-kv-certificate:3.4.2' = {
  name: 'create-${certificateName}'
  params: {
    akvName: vault.name
    location: location
    certificateNames: [certificateName]
    certificateCommonNames: [certificateCommonName]
    validity: validityInMonths
  }
}

output location string = location
output name string = vault.name
output resourceGroupName string = resourceGroup().name
output resourceId string = vault.id
output certificateSecretId string = certificate.outputs.certificateSecretIds[0]
output certificateThumbprint string = certificate.outputs.certificateThumbprintHexs[0]
