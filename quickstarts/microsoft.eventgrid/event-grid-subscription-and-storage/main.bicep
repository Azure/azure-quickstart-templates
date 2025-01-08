@description('Provide a unique name for the Blob Storage account.')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Provide a location for the Blob Storage account that supports Event Grid.')
param location string = resourceGroup().location

@description('Provide a name for the Event Grid subscription.')
param eventSubName string = 'subToStorage'

@description('Provide the URL for the WebHook to receive events. Create your own endpoint for events.')
param endpoint string

@description('Provide a name for the system topic.')
param systemTopicName string = 'mystoragesystemtopic'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource systemTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
  name: systemTopicName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: storageAccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-12-15-preview' = {
  parent: systemTopic
  name: eventSubName
  properties: {
    destination: {
      properties: {
        endpointUrl: endpoint
      }
      endpointType: 'WebHook'
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
        'Microsoft.Storage.BlobDeleted'
      ]
    }
  }
}

output name string = eventSubscription.name
output resourceId string = eventSubscription.id
output resourceGroupName string = resourceGroup().name
output location string = location
