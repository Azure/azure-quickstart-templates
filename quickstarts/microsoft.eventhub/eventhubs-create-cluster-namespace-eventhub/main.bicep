@description('Name for the Event Hub cluster.')
param clusterName string

@description('Name for the Event Hub cluster.')
param namespaceName string

@description('Name for the Event Hub to be created in the Event Hub namespace within the Event Hub cluster.')
param eventHubName string

@description('Specifies the Azure location for all resources.')
param location string = resourceGroup().location

resource cluster 'Microsoft.EventHub/clusters@2021-11-01' = {
  name: clusterName
  location: location
  sku: {
    name: 'Dedicated'
    capacity: 1
  }
}

resource namespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: namespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    clusterArmId: cluster.id
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  parent: namespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}
