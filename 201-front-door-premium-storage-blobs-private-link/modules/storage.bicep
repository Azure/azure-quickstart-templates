param location string {
  metadata: {
    description: 'The location into which the storage account should be deployed.'
  }
}
param accountName string {
  metadata: {
    description: 'The name of the Azure Storage account to create. This must be globally unique.'
  }
}
param skuName string {
  allowed: [
    'Standard_LRS'
    'Standard_GRS'
    'Standard_ZRS'
    'Premium_LRS'
  ]
  metadata: {
    description: 'The name of the SKU to use when creating the Azure Storage account.'
  }
}
param blobContainerName string {
  metadata: {
    description: 'The name of the Azure Storage blob container to create.'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2020-08-01-preview' = {
  name: '${storageAccount.name}/default/${blobContainerName}'
  properties:{
    publicAccess: 'None'
  }
}

output blobEndpointHostName string = replace(replace(storageAccount.properties.primaryEndpoints.blob, 'https://', ''), '/', '')
output storageResourceId string = storageAccount.id
output storageLocation string = storageAccount.location
