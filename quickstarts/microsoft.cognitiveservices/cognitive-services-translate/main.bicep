@description('Display name of Text Translation API account')
param aiServicesName string = 'textTranslation-${uniqueString(resourceGroup().id)}'

@description('SKU for Text Translation API')
@allowed([
  'F0'
  'S1'
  'S2'
  'S3'
  'S4'
])
param SKU string = 'S1'

@description('Location for the account')
param translateLocation string

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServicesName
  location: translateLocation
  kind: 'TextTranslation'
  sku: {
    name: SKU
  }
  properties: {
  }
}
