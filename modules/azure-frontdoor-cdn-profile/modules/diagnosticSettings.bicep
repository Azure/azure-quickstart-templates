@sys.description('Name of CDN Profile. For chaining, use output from parent module')
param cdnProfileName string

@sys.description('Event Hub Name')
param eventHubName string

@sys.description('Event Hub Namespace Name')
param eventHubNamespace string

@sys.description('Event Hub Namespace Subscription Id.')
param eventHubNamespaceSubscriptionId string 

@sys.description('Event Hub Namespace Resource Group')
param eventHubNamespaceResourceGroup string


resource event_hub_ns 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: eventHubNamespace
  scope: resourceGroup(eventHubNamespaceSubscriptionId, eventHubNamespaceResourceGroup)
}

resource event_hub_afd_cdn_logs 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' existing = {
  name: eventHubName
  parent: event_hub_ns
}

resource event_hub_namespace_auth_id 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' existing = {
  name: 'RootManageSharedAccessKey'
  parent: event_hub_ns
}

resource cdn 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: cdnProfileName
  scope: resourceGroup()
}

var diagnosticSettings = [
  {
    name: 'azure-afd-cdn-logs-diagnostic-settings'
    eventHub: event_hub_afd_cdn_logs.name
    eventHubAuthorizationRuleId: event_hub_namespace_auth_id.id
    logSettings: [
      {
        name: 'FrontDoorAccessLog'
        enabled: true
      }
      {
        name: 'FrontDoorWebApplicationFirewallLog'
        enabled: false
      }
      {
        name: 'FrontDoorHealthProbeLog'
        enabled: false
      }
    ]
  }
]

resource diagnostic_setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (dg, index) in diagnosticSettings: {
  scope: cdn
  name: dg.name
  properties: {
    eventHubName: dg.eventHub
    eventHubAuthorizationRuleId: dg.eventHubAuthorizationRuleId
    logs: [for (logCategory, index) in dg.logSettings: {
      category: logCategory.name
      enabled: logCategory.enabled
      retentionPolicy: {
        enabled: false
        days: 0
      }
    }]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}]
