param eventHubNsName string
param eventHubName string
param eventHubSendPolicyName string = 'evt-hub-apim-send-policy'
param eventHubListenPolicy string = 'evt-hub-app-consume-policy'
param ehNsSkuName string = 'Standard'
param ehNsSkuTier string = 'Standard'
param ehNsSkuCapacity int = 1
param ehNsIsAutoInflateEnabled bool = false
param ehNsMaximumThroughputUnits int = 0
param ehNsZoneRedundant bool = false

@description('Number of days to retain messages in eventhub')
param messageRetentionInDays int = 1
param tags object = {}

@description('Location for all resources.')
param location string

resource eventHubNs 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: eventHubNsName
  location: location
  tags: tags
  sku: {
    name: ehNsSkuName
    tier: ehNsSkuTier
    capacity: ehNsSkuCapacity
  }
  properties: {
    isAutoInflateEnabled: ehNsIsAutoInflateEnabled
    maximumThroughputUnits: ehNsMaximumThroughputUnits
    zoneRedundant: ehNsZoneRedundant
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  parent : eventHubNs
  name: eventHubName
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: 2
    status: 'Active'
  }
}

resource ehUniqApimSendPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  parent: eventHub
  name: eventHubSendPolicyName
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource ehUniqAppListenPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  parent: eventHubNs
  name: eventHubListenPolicy
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

output eventHubNsName string = eventHubNsName
output eventHubName string = eventHubName
output eventHubSendPolicyName string = eventHubSendPolicyName
output eventHubListenPolicy string = eventHubListenPolicy
output eventHubSendResourceId string = ehUniqApimSendPolicy.id
output eventHubListenResourceId string = ehUniqAppListenPolicy.id
