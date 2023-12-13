@description('Event Hub Namespace Name')
param eventHubNameSpace string

@description('Event Hub Name')
param eventHubName string

@description('Event Hub Namespace location')
param eventHubLocation string

resource eventhub_namespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: eventHubNameSpace
  location: eventHubLocation
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 20
  }
  properties: {
    minimumTlsVersion: '1.0'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
    isAutoInflateEnabled: true
    maximumThroughputUnits: 20
    kafkaEnabled: true
  }
}

resource eventhub_auth_rule 'Microsoft.EventHub/namespaces/AuthorizationRules@2022-01-01-preview' = {
  parent: eventhub_namespace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource eventhub_instance 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  parent: eventhub_namespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 20
    status: 'Active'
  }
}

resource eventhub_namespace_nw_rulesets 'Microsoft.EventHub/namespaces/networkRuleSets@2022-01-01-preview' = {
  parent: eventhub_namespace
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
  }
}

resource consumer_group 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  parent: eventhub_instance
  name: '$Default'
}

output eventHubName string = eventhub_instance.name
output eventHubAuthId string = eventhub_auth_rule.id