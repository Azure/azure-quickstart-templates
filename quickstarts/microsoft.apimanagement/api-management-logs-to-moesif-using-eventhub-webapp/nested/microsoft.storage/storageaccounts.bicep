@description('The name for storage account. Max 24 chars. a-z A-Z 0-9 no special characters or spaces. Used in DNS url')
param storageAccountName string
param storageAccountType string = 'Standard_LRS'
param storageKind string = 'StorageV2'
param tags object

@description('Location for all resources. eg \'westus2\'')
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageAccountType
  }
  kind: storageKind
}

output storageAccountName string = storageAccountName
