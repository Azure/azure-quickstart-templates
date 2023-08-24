param vWANhubs array
param vWANHub1ID string
param vWANHub2ID string
param vpnGatewayScaleUnit int
param logAnalyticsWorkspaceID string
//param logAnalyticsWorkspaceRetentionDays int

var defaultASN = 65515
var defaultPeerWeight = 0

resource hub1VPNs2sGateway 'Microsoft.Network/vpnGateways@2023-04-01' = {
  name: '${vWANhubs[0].name}-VPNs2sGateway'
  location: vWANhubs[0].location
  properties: {
    virtualHub: {
      id: vWANHub1ID
    }
    bgpSettings: {
      asn: defaultASN
      peerWeight: defaultPeerWeight
    }
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    enableBgpRouteTranslationForNat: false
    isRoutingPreferenceInternet: false
  }
}

resource S2SvpnGw1DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vWANhubs[0].name}-VPNs2sGateway-DiagnosticSettings' 
  scope: hub1VPNs2sGateway
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

resource hub2VPNs2sGateway 'Microsoft.Network/vpnGateways@2023-04-01' = {
  name: '${vWANhubs[1].name}-VPNs2sGateway'
  location: vWANhubs[1].location
  properties: {
    virtualHub: {
      id: vWANHub2ID
    }
    bgpSettings: {
      asn: defaultASN
      peerWeight: defaultPeerWeight
    }
    vpnGatewayScaleUnit: vpnGatewayScaleUnit 
    enableBgpRouteTranslationForNat: false
    isRoutingPreferenceInternet: false
  }
}

resource S2SvpnGw2DiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vWANhubs[1].name}-VPNs2sGateway_DiagnosticSettings'  
  scope: hub2VPNs2sGateway
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

output vpnGatewayConfigs array = [
   hub1VPNs2sGateway.properties.ipConfigurations
   hub2VPNs2sGateway.properties.ipConfigurations
]
