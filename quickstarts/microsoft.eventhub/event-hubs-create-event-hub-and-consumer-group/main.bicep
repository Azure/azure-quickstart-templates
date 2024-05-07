@description('Name of EventHub namespace')
param namespaceName string

@description('The messaging tier for service Bus namespace')
@allowed([
  'Basic'
  'Standard'
])
param eventhubSku string = 'Standard'

@description('MessagingUnits for premium namespace')
@allowed([
  1
  2
  4
])
param skuCapacity int = 1

@description('Name of Event Hub')
param eventHubName string

@description('Name of Consumer Group')
param consumerGroupName string

@description('Location for all resources.')
param location string = resourceGroup().location

resource namespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: namespaceName
  location: location
  sku: {
    name: eventhubSku
    tier: eventhubSku
    capacity: skuCapacity
  }
  tags: {
    tag1: 'value1'
    tag2: 'value2'
  }
  properties: {
  }
}

resource namespaceName_eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: namespace
  name: eventHubName
  properties: {
  }
}

resource namespaceName_eventHubName_consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-10-01-preview' = {
  parent: namespaceName_eventHub
  name: consumerGroupName
  properties: {
    userMetadata: 'User Metadata goes here'
  }
}
