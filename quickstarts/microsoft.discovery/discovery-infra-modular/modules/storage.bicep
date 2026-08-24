// Storage module: Azure Storage account (CORS-enabled for Discovery Studio and
// VS Code) plus a blob container for Discovery outputs. Skip this module and pass
// an existing storage account to main.bicep (deployStorage = false) to reuse one.

@description('Azure region for the storage account.')
param location string = resourceGroup().location

@description('Globally unique storage account name (3-24 lowercase alphanumeric characters).')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stg${uniqueString(resourceGroup().id)}'

@description('Replication SKU for the storage account.')
@allowed([
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
])
param storageAccountSku string = 'Standard_GRS'

@description('Name of the blob container for Discovery outputs. Discovery expects a container named "discoveryoutputs". Must be 3-63 lowercase letters, numbers, and hyphens.')
@minLength(3)
@maxLength(63)
param blobContainerName string = 'discoveryoutputs'

@description('Subnet resource IDs granted access via virtual network rules. Leave empty to skip network rules.')
param allowedSubnetIds string[] = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    // defaultAction stays 'Allow' because the Microsoft.Discovery control plane is
    // not yet on the Storage trusted-services bypass list; the virtual network rules
    // below are pre-configured to enforce once Discovery supports trusted access.
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        for subnetId in allowedSubnetIds: {
          id: subnetId
          action: 'Allow'
        }
      ]
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            'https://studio.discovery.microsoft.com'
            'https://*.vscode-cdn.net'
            'https://vscode.dev'
          ]
          allowedMethods: [
            'GET'
            'HEAD'
            'DELETE'
            'PUT'
          ]
          allowedHeaders: [
            '*'
          ]
          exposedHeaders: [
            '*'
          ]
          maxAgeInSeconds: 200
        }
      ]
    }
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: blobContainerName
  properties: {
    publicAccess: 'None'
  }
}

@description('Resource ID of the storage account.')
output resourceId string = storageAccount.id

@description('Name of the storage account.')
output name string = storageAccount.name

@description('Name of the blob container.')
output blobContainerName string = blobContainer.name
