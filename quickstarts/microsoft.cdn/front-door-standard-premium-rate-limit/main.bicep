@description('The name of the Front Door endpoint to create. This must be globally unique.')
param endpointName string = 'afd-${uniqueString(resourceGroup().id)}'

@description('The host name that should be used when connecting from Front Door to the origin.')
param originHostName string

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

@description('The mode that the WAF should be deployed using. In "Prevention" mode, the WAF will block requests it detects as malicious. In "Detection" mode, the WAF will not block requests and will simply log the request.')
@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Prevention'

@description('The number of requests per client IP address within the specified duration.')
param rateLimitThreshold int = 10

@description('The duration at which the rate limit should be applied.')
param rateLimitDurationInMinutes int = 5

var profileName = 'MyFrontDoor'
var originGroupName = 'MyOriginGroup'
var originName = 'MyOrigin'
var routeName = 'MyRoute'
var wafPolicyName = 'WafPolicy'
var securityPolicyName = 'SecurityPolicy'
var documentationIPAddressRange = '192.0.2.0/24' // This is the TEST-NET-1 documentation IP address range.

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: endpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: originGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: originName
  parent: originGroup
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: routeName
  parent: endpoint
  dependsOn:[
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: wafPolicyName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: wafMode
    }
    customRules: {
      rules: [
        {
          name: 'ApplyRateLimit'
          priority: 100
          enabledState: 'Enabled'
          ruleType: 'RateLimitRule'
          rateLimitThreshold: rateLimitThreshold
          rateLimitDurationInMinutes: rateLimitDurationInMinutes
          action: 'Block'
          matchConditions: [
            // Currently Front Door requires that a rate limit rule has a match condition. This specifies the subset
            // of requests it should apply to. For this sample, we are using an IP address-based match condition
            // and setting the value to "not 192.0.2.0/24". This is an IANA documentation range and no real clients
            // will use that range, so this match condition effectively matches all requests.
            // Note that the rate limit is applied per IP address.
            {
              matchVariable: 'RemoteAddr'
              operator: 'IPMatch'
              negateCondition: true
              matchValue: [
                documentationIPAddressRange
              ]
            }
          ]
        }
      ]
    }
  }
}

resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2021-06-01' = {
  parent: profile
  name: securityPolicyName
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: endpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

output frontDoorEndpointHostName string = endpoint.properties.hostName
