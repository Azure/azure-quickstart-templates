param location string = resourceGroup().location

@minLength(3)
@maxLength(24)  
param name string = 'sasvill007'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_RAGRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param type string = 'Standard_LRS'

var containerName = 'images'

resource stacc 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name:name
  location:location
  kind:'StorageV2'
  sku:{
  name:type
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${stacc.name}/default/${containerName}'
}

output storageID string = stacc.id
