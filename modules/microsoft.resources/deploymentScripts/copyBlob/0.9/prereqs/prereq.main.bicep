param location string = resourceGroup().location

var storageAccountName_var = 'storage${uniqueString(resourceGroup().id)}'

resource storageAccountName 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName_var
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
  }
}

output storageAccountName string = storageAccountName_var
output storageAccountResourceGroupName string = resourceGroup().name