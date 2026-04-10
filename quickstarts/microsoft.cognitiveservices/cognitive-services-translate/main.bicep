@description('Display name of the Azure AI Language resource')
param aiServicesName string = 'textTranslation-${uniqueString(resourceGroup().id)}'

@description('SKU for Text Translation API')
@allowed([
  'F0'
  'S1'
  'S2'
  'S3'
  'S4'
])
param sku string = 'S1'

@description('Location for the resource')
param translateLocation string

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServicesName
  location: translateLocation
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'TextTranslation'
  sku: {
    name: sku
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true
  }
}
