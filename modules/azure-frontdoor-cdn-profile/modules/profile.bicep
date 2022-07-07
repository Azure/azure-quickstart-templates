@allowed([
  'Premium_AzureFrontDoor'
  'Standard_AzureFrontDoor'
])
@sys.description('Name of Azure CDN SKU')
param skuName string

@sys.description('Name of CDN Profile')
param cdnProfileName string 

@sys.description('AFD Endpoint Name')
param afdEndpointName string

@sys.description('AFD Endpoint State')
param enableAfdEndpoint bool

@sys.description('Tags to identify resource owner')
param cdnProfileTags object

@sys.description('Custom Domain List')
param customDomains array

@sys.description('Origin List')
param origins array 

@sys.description('Event Hub Name')
param eventHubName string

@sys.description('Event Hub Namespace Name')
param eventHubNamespace string

@sys.description('Event Hub Namespace location')
param eventHubLocation string

@sys.description('Name of the WAF policy to create.')
param wafPolicyName string

@sys.description('Id of the WAF policy to attach')
param wafPolicyId string

@sys.description('Create CDN Profile')
resource cdn 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: cdnProfileName
  location: 'Global'
  tags: cdnProfileTags
  sku: {
    name: skuName
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

@sys.description('Create AFD Endpoint')
resource afd_endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  parent: cdn
  name: afdEndpointName
  location: 'Global'
  properties: {
    enabledState: enableAfdEndpoint ? 'Enabled' : 'Disabled'
  }
}

@sys.description('Create Custom Domains to be used for CDN profile')
resource custom_domains 'Microsoft.Cdn/profiles/customdomains@2021-06-01' = [for (customdomain, index) in customDomains: {
  parent: cdn
  name: replace(customdomain.hostname, '.', '-')
  properties: {
    hostName: customdomain.hostname
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
      }
  }
}]

@sys.description('List of Origin Groups')
resource origin_groups 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = [for (group, index) in origins: {
  parent: cdn
  name: group.originGroupName
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}]

@sys.description('List of origin and mapping to Origin Groups')
resource cdn_origins 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for (origin, index) in origins: {
  parent: origin_groups[index]
  name: replace(origin.hostname, '.', '-')
  properties: {
    hostName: origin.hostname
    httpPort: 80
    httpsPort: 443
    originHostHeader: origin.hostname
    priority: 1
    weight: 1000
    enabledState: origin.enabledState ? 'Enabled' : 'Disabled'
    enforceCertificateNameCheck: true
  }
}]

// Create an Array of all Endpoint which includes customDomain Id and afdEndpoint Id
// This array is needed to be attached to Microsoft.Cdn/profiles/securitypolicies
var customDomainIds = [for (domain, index) in customDomains: {id: custom_domains[index].id}]
var afdEndpointIds = [{id: afd_endpoint.id}]
var endPointIdsForWaf = union(customDomainIds, afdEndpointIds)

@sys.description('Attach WAF for Security policy')
resource cdn_waf_security_policy 'Microsoft.Cdn/profiles/securitypolicies@2021-06-01' = {
  parent: cdn
  name: wafPolicyName
  properties: {
    parameters: {
      wafPolicy: {
        id: wafPolicyId
      }
      associations: [
        {
          domains: endPointIdsForWaf
          patternsToMatch: [
            '/*'
          ]
        }
      ]
      type: 'WebApplicationFirewall'
    }
  }
}

@sys.description('Create EventHub.')
module eventhub 'eventhub.bicep' = {
  name: '${cdnProfileName}-eventhub-module'
  params: {
    eventHubNameSpaceName: eventHubNamespace
    eventHubName: eventHubName
    eventHubLocation: eventHubLocation
  }
}

@sys.description('Default Rule Sets.')
module rulesets 'rulesets.bicep' = {
  name: '${cdnProfileName}-rulesets-module'
  params: {
    cdnProfileName: cdn.name
  }
}

@sys.description('Create Diagnostic Settings for Logs')
module diagnostic_settings 'diagnosticsettings.bicep' = {
  name: '${cdnProfileName}-monitoring-module'
  params: {
    cdnProfileName: cdn.name
    eventHubName: eventhub.outputs.eventHubName
    eventHubAuthId: eventhub.outputs.eventHubAuthId
  }
  dependsOn:[
    eventhub
  ]
}

output cdnName string = cdn.name
output afdEndpointName string = afd_endpoint.name
output defaultRuleSets array = rulesets.outputs.defaultRuleSets