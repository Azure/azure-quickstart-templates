param vWANhubs array
param vWANHub1ID string
param vWANHub2ID string
param ErGatewayScaleUnit int
param LogAnalyticsWorkspaceID string
param LogAnalyticsWorkspaceRetentionDays int 

resource Hub1ErGateway 'Microsoft.Network/expressRouteGateways@2022-11-01' = {
  name: '${vWANhubs[0].name}-ErGateway'
  location: vWANhubs[0].location
  properties: {
    virtualHub: {
      id: vWANHub1ID
    }
    expressRouteConnections: []
    allowNonVirtualWanTraffic: false
    autoScaleConfiguration: {
      bounds: {
        min: ErGatewayScaleUnit
      }
    }
  }
}

resource ErGw1_DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vWANhubs[0].name}-ErGatewayDiagnosticSettings'
  scope: Hub1ErGateway
  properties: {
    workspaceId: LogAnalyticsWorkspaceID
    logs: [       
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: LogAnalyticsWorkspaceRetentionDays
        }
      }
    ]
  }
}

resource Hub2ErGateway 'Microsoft.Network/expressRouteGateways@2022-11-01' = {
  name: '${vWANhubs[1].name}-ErGateway'
  location: vWANhubs[1].location
  properties: {
    virtualHub: {
      id: vWANHub2ID
    }
    expressRouteConnections: []
    allowNonVirtualWanTraffic: false
    autoScaleConfiguration: {
      bounds: {
        min: ErGatewayScaleUnit
      }
    }
  }
}

resource ErGw2_DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vWANhubs[1].name}-ErGatewayDiagnosticSettings'
  scope: Hub2ErGateway
  properties: {
    workspaceId: LogAnalyticsWorkspaceID
    logs: [     
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true 
          days: LogAnalyticsWorkspaceRetentionDays
        }
      }
    ]
  }
}
