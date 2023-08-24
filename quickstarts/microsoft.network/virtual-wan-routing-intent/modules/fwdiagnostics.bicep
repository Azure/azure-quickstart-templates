param vWANhubs array
param logAnalyticsWorkspaceID string
// param logAnalyticsWorkspaceRetentionDays int

resource hub1Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: vWANhubs[0].fwname
}

resource hub2Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: vWANhubs[1].fwname
}

resource Firewall1DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vWANhubs[0].fwname}-DiagnosticSettings'
  scope: hub1Firewall
  properties: {
    workspaceId: logAnalyticsWorkspaceID
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        /* retentionPolicy: {
          enabled: true
          days: logAnalyticsWorkspaceRetentionDays
        } */
      }      
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
       /* retentionPolicy: {
          enabled: true
          days: logAnalyticsWorkspaceRetentionDays
        } */
      }
    ]
  }
}

resource Firewall2DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vWANhubs[1].fwname}-DiagnosticSettings' 
  scope: hub2Firewall
  properties: {
    workspaceId: logAnalyticsWorkspaceID
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
       /* retentionPolicy: {
          enabled: true
          days: logAnalyticsWorkspaceRetentionDays
        } */
      }      
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        /* retentionPolicy: {
          enabled: true
          days: logAnalyticsWorkspaceRetentionDays
        } */
      }
    ]
  }
}
