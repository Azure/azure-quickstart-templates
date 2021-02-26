param location string = resourceGroup().location
param storageAccountName string
param storageSkuName string {
  allowed: [
    'Standard_LRS'
    'Standard_GRS'
    'Standard_ZRS'
    'Premium_LRS'
  ]
  default: 'Standard_LRS'
}
param storageBlobContainerName string
param frontDoorEndpointName string

var frontDoorSkuName = 'Premium_AzureFrontDoor'

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    accountName: storageAccountName
    skuName: storageSkuName
    blobContainerName: storageBlobContainerName
  }
}

module frontDoor 'modules/front-door.bicep' = {
  name: 'front-door'
  params: {
    skuName: frontDoorSkuName
    endpointName: frontDoorEndpointName
    originHostName: storage.outputs.blobEndpointHostName
    originPath: '/${storageBlobContainerName}'
    privateEndpointResourceId: storage.outputs.storageResourceId
    privateLinkResourceType: 'blob' // For blobs on Azure Storage, this needs to be 'blob'.
    privateEndpointLocation: location
  }
}

output frontDoorEndpointHostName string = frontDoor.outputs.frontDoorEndpointHostName
output blobEndpointHostName string = storage.outputs.blobEndpointHostName
