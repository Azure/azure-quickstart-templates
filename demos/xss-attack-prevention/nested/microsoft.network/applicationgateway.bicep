@description('application gateway size')
@allowed([
  'WAF_Medium'
  'WAF_Large'
])
param applicationGatewaySize string = 'WAF_Medium'

@description('Number of instances')
@minValue(2)
@maxValue(10)
param capacity int = 2

@description('WAF Enabled')
param wafEnabled bool = true

@description('WAF Mode')
@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Detection'

@description('WAF Rule Set Type')
@allowed([
  'OWASP'
])
param wafRuleSetType string = 'OWASP'

@description('WAF Rule Set Version')
@allowed([
  '2.2.9'
  '3.0'
])
param wafRuleSetVersion string = '3.0'
param applicationGatewayName string
param publicIPRef string
param frontendPorts array
param gatewayIPConfigurations array
param backendAddressPools array
param backendHttpSettingsCollection array
param httpListeners array
param requestRoutingRules array
param probes array
param omsWorkspaceResourceId string
param location string

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: applicationGatewaySize
      tier: 'WAF'
      capacity: capacity
    }
    gatewayIPConfigurations: gatewayIPConfigurations
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: publicIPRef
          }
        }
      }
    ]
    frontendPorts: frontendPorts
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    httpListeners: httpListeners
    requestRoutingRules: requestRoutingRules
    webApplicationFirewallConfiguration: {
      enabled: wafEnabled
      firewallMode: wafMode
      ruleSetType: wafRuleSetType
      ruleSetVersion: wafRuleSetVersion
    }
    probes: probes
    sslPolicy: {
      disabledSslProtocols: [
        'TLSv1_0'
        'TLSv1_1'
      ]
    }
  }
}

resource applicationGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGateway
  name: 'service'
  properties: {
    workspaceId: omsWorkspaceResourceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: false
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
