@description('Specifies the location of AKS cluster.')
param location string

@description('Specifies the resource ID of the log analytics workspace')
param workspaceId string

@description('Specifies the name of the Application Gateway.')
param applicationGatewayName string

param applicationGatewaySubnetId string

@description('Specifies the name of the WAF policy')
param wafPolicyName string

@description('Specifies the mode of the WAF policy.')
@allowed([
  'Detection'
  'Prevention'
])
param wafPolicyMode string

@description('Specifies the state of the WAF policy.')
@allowed([
  'Enabled'
  'Disabled '
])
param wafPolicyState string

@description('Specifies the maximum file upload size in Mb for the WAF policy.')
param wafPolicyFileUploadLimitInMb int

@description('Specifies the maximum request body size in Kb for the WAF policy.')
param wafPolicyMaxRequestBodySizeInKb int

@description('Specifies the whether to allow WAF to check request Body.')
param wafPolicyRequestBodyCheck bool

@description('Specifies the rule set type.')
param wafPolicyRuleSetType string

@description('Specifies the rule set version.')
param wafPolicyRuleSetVersion string

param applicationGatewayUserDefinedManagedIdentityId string

var applicationGatewayPublicIPAddressName = '${applicationGatewayName}PublicIp'
var applicationGatewayUserDefinedManagedIdentityName = '${applicationGatewayName}ManagedIdentity'

var applicationGatewayIPConfigurationName = 'applicationGatewayIPConfiguration'
var applicationGatewayFrontendIPConfigurationName = 'applicationGatewayFrontendIPConfiguration'
var applicationGatewayFrontendIPConfigurationId = resourceId(
  'Microsoft.Network/applicationGateways/frontendIPConfigurations',
  applicationGatewayName,
  applicationGatewayFrontendIPConfigurationName
)
var applicationGatewayFrontendPortName = 'applicationGatewayFrontendPort'
var applicationGatewayFrontendPortId = resourceId(
  'Microsoft.Network/applicationGateways/frontendPorts',
  applicationGatewayName,
  applicationGatewayFrontendPortName
)
var applicationGatewayHttpListenerName = 'applicationGatewayHttpListener'
var applicationGatewayHttpListenerId = resourceId(
  'Microsoft.Network/applicationGateways/httpListeners',
  applicationGatewayName,
  applicationGatewayHttpListenerName
)
var applicationGatewayBackendAddressPoolName = 'applicationGatewayBackendPool'
var applicationGatewayBackendAddressPoolId = resourceId(
  'Microsoft.Network/applicationGateways/backendAddressPools',
  applicationGatewayName,
  applicationGatewayBackendAddressPoolName
)
var applicationGatewayBackendHttpSettingsName = 'applicationGatewayBackendHttpSettings'
var applicationGatewayBackendHttpSettingsId = resourceId(
  'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
  applicationGatewayName,
  applicationGatewayBackendHttpSettingsName
)
var applicationGatewayRequestRoutingRuleName = 'default'

resource applicationGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: applicationGatewayPublicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGatewayUserDefinedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: applicationGatewayUserDefinedManagedIdentityName
  location: location
}

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-01-01' = {
  name: wafPolicyName
  location: location
  properties: {
    customRules: [
      {
        name: 'BlockMe'
        priority: 1
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'QueryString'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'blockme'
            ]
          }
        ]
      }
      {
        name: 'BlockEvilBot'
        priority: 2
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'User-Agent'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'evilbot'
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: wafPolicyRequestBodyCheck
      maxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
      fileUploadLimitInMb: wafPolicyFileUploadLimitInMb
      mode: wafPolicyMode
      state: wafPolicyState
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: wafPolicyRuleSetType
          ruleSetVersion: wafPolicyRuleSetVersion
        }
      ]
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2024-01-01' = {
  name: applicationGatewayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayUserDefinedManagedIdentityId}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: applicationGatewayIPConfigurationName
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: applicationGatewayFrontendIPConfigurationName
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: applicationGatewayFrontendPortName
        properties: {
          port: 80
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
    enableHttp2: false
    probes: [
      {
        name: 'defaultHttpProbe'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
        }
      }
      {
        name: 'defaultHttpsProbe'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
        }
      }
    ]
    backendAddressPools: [
      {
        name: applicationGatewayBackendAddressPoolName
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: applicationGatewayBackendHttpSettingsName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: applicationGatewayHttpListenerName
        properties: {
          firewallPolicy: {
            id: wafPolicy.id
          }
          frontendIPConfiguration: {
            id: applicationGatewayFrontendIPConfigurationId
          }
          frontendPort: {
            id: applicationGatewayFrontendPortId
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: applicationGatewayRequestRoutingRuleName
        properties: {
          priority: 1
          ruleType: 'Basic'
          httpListener: {
            id: applicationGatewayHttpListenerId
          }
          backendAddressPool: {
            id: applicationGatewayBackendAddressPoolId
          }
          backendHttpSettings: {
            id: applicationGatewayBackendHttpSettingsId
          }
        }
      }
    ]
    firewallPolicy: {
      id: wafPolicy.id
    }
  }
}

resource applicationGatewayDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGateway
  name: '${applicationGatewayName}-Diag'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output applicationGatewayId string = applicationGateway.id
