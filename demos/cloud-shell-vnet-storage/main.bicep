@description('Name of the virtual network to use for cloud shell containers.')
param existingVNETName string

@description('Name of the subnet to use for storage account.')
param existingStorageSubnetName string

@description('Name of the subnet to use for cloud shell containers.')
param existingContainerSubnetName string

@description('Name of the storage account in subnet.')
param storageAccountName string

@description('Name of the fileshare in storage account.')
param fileShareName string = 'acsshare'

@description('Name of the resource tag')
param resourceTags object = {
  Environment: 'cloudshell'
}

@description('Location for all resources.')
param location string = resourceGroup().location

var containerSubnetRef = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  existingVNETName,
  existingContainerSubnetName
)
var storageSubnetRef = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  existingVNETName,
  existingStorageSubnetName
)

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  tags: resourceTags
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'None'
      virtualNetworkRules: [
        {
          id: containerSubnetRef
          action: 'Allow'
        }
        {
          id: storageSubnetRef
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Cool'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  parent: fileServices
  name: fileShareName
  properties: {
    shareQuota: 6
  }
}
