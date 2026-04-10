@description('Display name of the Azure AI Vision resource')
param aiServicesName string = 'computerVision-${uniqueString(resourceGroup().id)}'

@description('SKU for Computer Vision API')
@allowed([
  'F0'
  'S1'
])
param sku string = 'F0'

@description('Location of the resource group.')
param location string = resourceGroup().location

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServicesName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'ComputerVision'
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
