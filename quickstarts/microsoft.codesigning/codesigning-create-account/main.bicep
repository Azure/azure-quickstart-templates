@description('A signing account name.')
@minLength(3)
@maxLength(15)
param accountName string

@description('Location for the account.')
param location string = resourceGroup().location

@description('Sku for the resource.')
@allowed([
  'Premium'
  'Basic'
])
param skuName string = 'Basic'


resource account 'Microsoft.CodeSigning/codeSigningAccounts@2024-09-30-preview' = {
  location: location
  name: accountName
  properties: {
    sku: {
      name: skuName
    }
  }
}
