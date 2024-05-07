@description('Display name of Computer Vision API account')
param accountName string = 'computervision'

@description('SKU for Computer Vision API')
@allowed([
  'F0'
  'S1'
])
param SKU string = 'F0'

@description('Location for all resources.')
param location string = resourceGroup().location

resource account 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: accountName
  location: location
  kind: 'ComputerVision'
  sku: {
    name: SKU
  }
  properties: {
  }
}
