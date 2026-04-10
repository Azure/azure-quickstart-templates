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

@description('The subject name for the certificate (e.g., CN=contoso.com).')
param subjectName string = 'CN=contoso.com'

@description('The validity of the certificate in months.')
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

#disable-next-line BCP081
resource certificate 'Microsoft.KeyVault/vaults/certificates@2023-07-01' = {
  parent: vault
  name: certificateName
  properties: {
    issuerParameters: {
      name: 'Self'
    }
    keyProperties: {
      exportable: true
      keySize: 2048
      keyType: 'RSA'
      reuseKey: true
    }
    secretProperties: {
      contentType: 'application/x-pkcs12'
    }
    x509CertificateProperties: {
      subject: subjectName
      validityInMonths: validityInMonths
    }
  }
}

output location string = location
output name string = vault.name
output resourceGroupName string = resourceGroup().name
output resourceId string = vault.id
