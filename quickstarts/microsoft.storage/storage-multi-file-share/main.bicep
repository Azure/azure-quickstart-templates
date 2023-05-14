@description('Specifies the name of the Azure Storage account.')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Specifies the prefix of the file share names.')
param sharePrefix string = 'logs'

@description('Specifies the location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

@description('Specifies the number of file shares to be created.')
@minValue(1)
@maxValue(100)
param shareCopy int = 1

resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource fileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = [for i in range(0, shareCopy): {
  name: '${sa.name}/default/${sharePrefix}${i}'
}]
