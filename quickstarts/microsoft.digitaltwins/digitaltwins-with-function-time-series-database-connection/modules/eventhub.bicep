@description('Name of Event Hubs namespace')
param eventHubsNamespaceName string

@description('Name given to event hub')
param eventHubName string

@allowed([
  'Basic'
  'Premium'
  'Standard'
])
@description('Event Hubs namespace SKU option')
param eventHubsNamespacePlan string

@allowed([
  'Basic'
  'Standard'
])
@description('Event Hubs namespace SKU billing tier')
param eventHubsNamespaceTier string

@description('Event Hubs throughput units')
param eventHubsNamespaceCapacity int

@description('Number of days to retain data in event hub')
param retentionInDays int

@description('Number of partitions to create in event hub')
param partitionCount int

@description('Location of to be created resources')
param location string

// Creates Event Hubs namespace
resource eventHubsNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventHubsNamespaceName
  location: location
  sku: {
    capacity: eventHubsNamespaceCapacity
    name: eventHubsNamespacePlan
    tier: eventHubsNamespaceTier
  }
}

// Creates an event hub in the Event Hubs namespace
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: '${eventHubsNamespace.name}/${eventHubName}'
  properties: {
    messageRetentionInDays: retentionInDays
    partitionCount: partitionCount
  }
}
