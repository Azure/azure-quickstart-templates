@description('The location into which the Azure Storage resources should be deployed. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.')
@allowed([
  'eastus'
  'westus2'
  'southcentralus'
])
param location string

@description('The name of the Azure Storage account to create. This must be globally unique.')
param storageAccountName string = 'stor${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the Azure Storage account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageSkuName string = 'Standard_LRS'

@description('The name of the Azure Storage blob container to create.')
param storageBlobContainerName string = 'mycontainer'

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

var frontDoorSkuName = 'Premium_AzureFrontDoor' // This sample uses Private Link, which requires the premium SKU of Front Door.

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
