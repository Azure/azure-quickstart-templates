@description('The name must be unique across all existing storage account names in Azure. It must be 3 to 24 characters long, and can contain only lowercase letters and numbers.')
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}'

@description('Storage account location, default is same as resource group location.')
param location string = resourceGroup().location

@description('Storage account replication, for more info see \'https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy\'.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountReplication string = 'Standard_LRS'

@description('Enable or disable Advanced Threat Protection.')
param advancedThreatProtectionEnabled bool = true

resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountReplication
  }
  kind: 'StorageV2'
  properties: {}
}

resource atpSettings 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = if (advancedThreatProtectionEnabled) {
  name: 'current'
  scope: sa
  properties: {
    isEnabled: true
  }
}

output storageAccountName string = storageAccountName
output storageAccountId string = sa.id
