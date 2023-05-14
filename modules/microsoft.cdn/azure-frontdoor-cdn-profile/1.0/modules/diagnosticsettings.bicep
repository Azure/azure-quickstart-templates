@description('Name of CDN Profile. For chaining, use output from parent module')
param cdnProfileName string

@description('Event Hub Name')
param eventHubName string

@description('Event Hub AuthId')
param eventHubAuthId string

var diagnosticSettings = [
  {
    name: 'azure-afd-cdn-logs-diagnostic-settings'
    eventHub: eventHubName
    eventHubAuthorizationRuleId: eventHubAuthId
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

resource cdn 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: cdnProfileName
}

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