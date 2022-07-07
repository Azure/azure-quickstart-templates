@sys.description('Name of Azure CDN SKU')
param skuName string

@sys.description('Environment Name')
param envName string

@sys.description('Origin details')
param origins array

@sys.description('Custom Domain Array')
param customDomains array

@sys.description('Tags to identify resource owner')
param cdnProfileTags object

@sys.description('AFD Endpoint State')
param enableAfdEndpoint bool

@sys.description('Event Hub Name')
param eventHubName string

@sys.description('Event Hub Namespace Name')
param eventHubNamespace string

@sys.description('Event Hub Namespace location')
param eventHubLocation string

@sys.description('Describes if it is in detection mode or prevention mode at policy level.')
param wafPolicyMode string

@sys.description('Describes if the policy needs to enabled or disabled.')
param enableWAFPolicy bool

@sys.description('Crearte Azure WAF for CDN')
module waf 'modules/waf.bicep' = {
  name: 'afdcdn-${envName}-waf-module'
  params:  {
    skuName: skuName
    enableWAFPolicy: enableWAFPolicy
    wafPolicyMode: wafPolicyMode
    wafPolicyName: 'FrontDoorCdn${envName}WAF'
  }
}

module profile 'modules/profile.bicep' = {
  name: 'afdcdn-${envName}-profile-module'
  scope: resourceGroup()
  params:  {
    skuName: skuName
    cdnProfileName: 'afd-cdn-${envName}-profile'
    afdEndpointName: 'afd-cdn-${envName}' 
    enableAfdEndpoint: enableAfdEndpoint
    customDomains: customDomains
    origins: origins
    cdnProfileTags: cdnProfileTags
    wafPolicyName: waf.outputs.cdnWafName
    wafPolicyId: waf.outputs.cdnWafId
    eventHubName: eventHubName
    eventHubNamespace: eventHubNamespace
    eventHubLocation: eventHubLocation
  }
}

module routes 'modules/routes.bicep' = {
  name: 'afdcdn-${envName}-routes-module'
  params:  {
    cdnProfileName: profile.outputs.cdnName
    afdEndpointName: profile.outputs.afdEndpointName
    customDomains: customDomains
    routeRuleSets: profile.outputs.defaultRuleSets
    origins: origins
  }
  dependsOn:[
    profile
  ]
}