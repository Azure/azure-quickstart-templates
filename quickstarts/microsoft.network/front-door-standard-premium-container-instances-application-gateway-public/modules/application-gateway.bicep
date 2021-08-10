@description('The location into which the Application Gateway resources should be deployed.')
param location string

@description('The domain name label to attach to the Application Gateway\'s public IP address. This must be unique within the specified location.')
param publicIPAddressDomainNameLabel string = 'appgw${uniqueString(resourceGroup().id)}'

@description('The minimum number of capacity units for the Application Gateway to use when autoscaling.')
param minimumCapacity int = 2

@description('The maximum number of capacity units for the Application Gateway to use when autoscaling.')
param maximumCapacity int = 10

@description('The IP address of the backend to configure in Application Gateway.')
param backendIPAddress string

@description('Indicates that Application Gateway should override the host header in the request with the host name of the back-end when the request is routed from the Application Gateway to the backend.')
param pickHostNameFromBackendAddress bool = false

@description('The resource ID of the virtual network subnet that the Application Gateway should be deployed into.')
param subnetResourceId string

@description('The unique ID associated with the Front Door profile that will send traffic to this application. The Application Gateway WAF will be configured to disallow traffic that hasn\'t had this ID attached to it.')
param frontDoorId string

var publicIPAddressName = 'MyApplicationGateway-PIP'
var applicationGatewayName = 'MyApplicationGateway'
var gatewayIPConfigurationName = 'MyGatewayIPConfiguration'
var frontendIPConfigurationName = 'MyFrontendIPConfiguration'
var frontendPort = 80
var frontendPortName = 'MyFrontendPort'
var backendPort = 80
var backendAddressPoolName = 'MyBackendAddressPool'
var backendHttpSettingName = 'MyBackendHttpSetting'
var httpListenerName = 'MyHttpListener'
var requestRoutingRuleName = 'MyRequestRoutingRule'
var wafPolicyName = 'MyWAFPolicy'
var wafPolicyManagedRuleSetType = 'OWASP'
var wafPolicyManagedRuleSetVersion = '3.1'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: publicIPAddressDomainNameLabel
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    autoscaleConfiguration: {
      minCapacity: minimumCapacity
      maxCapacity: maximumCapacity
    }
    gatewayIPConfigurations: [
      {
        name: gatewayIPConfigurationName
        properties: {
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendIPConfigurationName
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendPortName
        properties: {
          port: frontendPort
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
        properties: {
          backendAddresses: [
            {
              ipAddress: backendIPAddress
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingName
        properties: {
          port: backendPort
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: pickHostNameFromBackendAddress
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, frontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, frontendPortName)
          }
          firewallPolicy: {
            id: wafPolicy.id
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: requestRoutingRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, httpListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, backendAddressPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, backendHttpSettingName)
          }
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetVersion: wafPolicyManagedRuleSetVersion
      ruleSetType: wafPolicyManagedRuleSetType
      requestBodyCheck: false
    }
    firewallPolicy: {
      id: wafPolicy.id
    }
  }
}

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-06-01' = {
  name: wafPolicyName
  location: location
  properties: {
    policySettings: {
      mode: 'Prevention'
      state: 'Enabled'
      requestBodyCheck: false
    }
    customRules: [
      {
        name: 'RequireCorrectFrontDoorIdHeader'
        ruleType: 'MatchRule'
        priority: 1
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'X-Azure-FDID'
              }
            ]
            negationConditon: true
            operator: 'Equal'
            matchValues: [
              frontDoorId
            ]
          }
        ]
      }
    ]
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: wafPolicyManagedRuleSetType
          ruleSetVersion: wafPolicyManagedRuleSetVersion
        }
      ]
    }
  }
}

output applicationGatewayResourceId string = applicationGateway.id
output publicIPAddressHostName string = publicIPAddress.properties.dnsSettings.fqdn
