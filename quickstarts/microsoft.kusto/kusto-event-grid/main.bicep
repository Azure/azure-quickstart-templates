@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the cluster')
param clusterName string = 'kusto${uniqueString(resourceGroup().id)}'

@description('Name of the sku')
param skuName string = 'Standard_D12_v2'

@description('# of nodes')
@minValue(2)
@maxValue(1000)
param skuCapacity int = 2

@description('Name of the database')
param databaseName string = 'kustodb'

@description('Name of storage account')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Name of storage account')
param storageContainerName string = 'landing'

@description('Name of Event Grid topic')
param eventGridTopicName string = 'main-topic'

@description('Name of Event Hub\'s namespace')
param eventHubNamespaceName string = 'eventHub${uniqueString(resourceGroup().id)}'

@description('Name of Event Hub')
param eventHubName string = 'storageHub'

@description('Name of Event Grid subscription')
param eventGridSubscriptionName string = 'toEventHub'

//  Storage account + container
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
  }

  resource blobServices 'blobServices' = {
    name: 'default'

    resource landingContainer 'containers' = {
      name: storageContainerName
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

//  Event hub receiving event grid notifications
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    capacity: 1
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {}

  resource eventHub 'eventhubs' = {
    name: eventHubName
    properties: {
      messageRetentionInDays: 2
      partitionCount: 2
    }

    resource kustoConsumerGroup 'consumergroups' = {
      name: 'kustoConsumerGroup'
      properties: {}
    }
  }
}

//  Here we setup an event grid topic and a subscription sending events to event hub

//  Event grid topic on storage account
resource blobTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
  name: eventGridTopicName
  location: location
  identity: {
    //  We give an identity to the Event Grid so we can give it permission to write into Event Hub
    type: 'SystemAssigned'
  }
  properties: {
    source: storage.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }

  //  Event Grid subscription, pushing events to event hub
  resource newBlobSubscription 'eventSubscriptions' = {
    name: eventGridSubscriptionName
    properties: {
      deliveryWithResourceIdentity: {
        destination: {
          endpointType: 'EventHub'
          properties: {
            resourceId: eventHubNamespace::eventHub.id
          }
        }
        identity: {
          type: 'SystemAssigned'
        }
      }
      eventDeliverySchema: 'EventGridSchema'
      filter: {
        subjectBeginsWith: '/blobServices/default/containers/${storage::blobServices::landingContainer.name}'
        includedEventTypes: [
          'Microsoft.Storage.BlobCreated'
        ]
        enableAdvancedFilteringOnArrays: true
      }
      retryPolicy: {
        maxDeliveryAttempts: 30
        eventTimeToLiveInMinutes: 1440
      }
    }
  }
}

//  Authorize topic to send to Event Hub
resource topicEventHubRbacAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(blobTopic.id, eventHubNamespace::eventHub.id, 'rbac')
  scope: eventHubNamespace::eventHub

  properties: {
    description: 'Azure Event Hubs Data Sender'
    principalId: blobTopic.identity.principalId
    principalType: 'ServicePrincipal'
    //  See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#analytics for built-in roles
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')
  }
}

//  Kusto cluster
resource cluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: clusterName
  location: location
  sku: {
    name: skuName
    tier: 'Standard'
    capacity: skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableStreamingIngest: true
  }

  resource kustoDb 'databases' = {
    name: databaseName
    location: location
    kind: 'ReadWrite'

    resource kustoScript 'scripts' = {
      name: 'db-script'
      properties: {
        scriptContent: loadTextContent('script.kql')
        continueOnErrors: false
      }
    }

    resource eventConnection 'dataConnections' = {
      name: 'eventConnection'
      location: location
      //  Here we need to explicitely declare dependencies
      //  Since we do not use those resources in the event connection
      //  but we do need them to be deployed first
      dependsOn: [
        //  We need the table to be present in the database
        kustoScript
        //  We need the cluster to be receiver on the Event Hub
        clusterEventHubAuthorization
      ]
      kind: 'EventGrid'
      properties: {
        blobStorageEventType: 'Microsoft.Storage.BlobCreated'
        consumerGroup: eventHubNamespace::eventHub::kustoConsumerGroup.name
        dataFormat: 'csv'
        eventGridResourceId: blobTopic::newBlobSubscription.id
        eventHubResourceId: eventHubNamespace::eventHub.id
        ignoreFirstRecord: true
        managedIdentityResourceId: cluster.id
        storageAccountResourceId: storage.id
        tableName: 'People'
      }
    }
  }
}

//  Authorize Kusto Cluster to receive event from Event Hub
resource clusterEventHubAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cluster.name, eventHubName, 'Azure Event Hubs Data Receiver')
  //  See https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources
  //  for scope for extension
  scope: eventHubNamespace::eventHub
  properties: {
    description: 'Give "Azure Event Hubs Data Receiver" to the cluster'
    principalId: cluster.identity.principalId
    //  Required in case principal not ready when deploying the assignment
    principalType: 'ServicePrincipal'
    //  See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#analytics for built-in roles
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'a638d3c7-ab3a-418d-83e6-5f17a39d4fde'
    )
  }
}

//  Authorize Kusto Cluster to read storage
resource clusterStorageAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cluster.name, storageContainerName, 'Storage Blob Data Contributor')
  //  See https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources
  //  for scope for extension
  scope: storage::blobServices
  properties: {
    description: 'Give "Storage Blob Data Contributor" to the cluster'
    principalId: cluster.identity.principalId
    //  Required in case principal not ready when deploying the assignment
    principalType: 'ServicePrincipal'
    //  See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage for built-in roles
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    )
  }
}
