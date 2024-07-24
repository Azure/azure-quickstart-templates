@description('Display name of Computer Vision API account')
param aiServicesName string = 'computerVision-${uniqueString(resourceGroup().id)}'

@description('SKU for Computer Vision API')
@allowed([
  'F0'
  'S1'
])
param SKU string = 'F0'

@description('Location for all resources.')
param location string = resourceGroup().location

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServicesName
  location: location
  kind: 'ComputerVision'
  sku: {
    name: SKU
  }
  properties: {
  }
}
