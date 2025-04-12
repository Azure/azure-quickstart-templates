@allowed([
  'Premium_AzureFrontDoor'
  'Standard_AzureFrontDoor'
])
@description('Name of Azure CDN SKU')
param skuName string = 'Premium_AzureFrontDoor'

@description('Environment Name')
param envName string

@description('Name of CDN Profile')
param cdnProfileName string = 'afd-cdn-${envName}-profile'

@description('AFD Endpoint Name')
param afdEndpointName string = 'afd-cdn-${envName}'

@description('Origin details')
param origins array

@description('Custom Domain Array')
param customDomains array

@description('Tags to identify resource owner')
param cdnProfileTags object = {
  envName: envName
}

@description('AFD Endpoint State')
param enableAfdEndpoint bool = true

@description('Event Hub Name')
param eventHubName string = 'eventhub-${uniqueString(resourceGroup().id)}'

@description('Event Hub Namespace Name')
param eventHubNamespace string = '${eventHubName}-ns'

@description('Event Hub Namespace location')
param eventHubLocation string = resourceGroup().location

@description('Name of the WAF policy to create.')
param wafPolicyName string = 'FrontDoorCdn${envName}WAF'

@allowed([
  'Detection'
  'Prevention'
])
@description('Describes if it is in detection mode or prevention mode at policy level.')
param wafPolicyMode string = 'Prevention'

@description('Describes if the policy needs to enabled or disabled.')
param enableWAFPolicy bool = true

@description('Response body to return on Block')
param wafBlockResponseBody string = 'Access Denied by Firewall.'

@allowed([
  401
  403
])
@description('Response Code to return on Block. Default to 403')
param wafBlockResponseCode int = 403

@description('Describes if request body should be checked. Since we only allow GET in this module due to Custom Rule, default to false')
param enableRequestBodyCheck bool = false

@description('Crearte Azure WAF for CDN')
module waf 'modules/waf.bicep' = {
  name: 'afdcdn-${envName}-waf-module'
  params:  {
    skuName: skuName
    enableWAFPolicy: enableWAFPolicy
    wafPolicyMode: wafPolicyMode
    wafPolicyName: wafPolicyName
    wafBlockResponseBody: wafBlockResponseBody
    wafBlockResponseCode: wafBlockResponseCode
    enableRequestBodyCheck: enableRequestBodyCheck
  }
}

module profile 'modules/profile.bicep' = {
  name: 'afdcdn-${envName}-profile-module'
  params:  {
    skuName: skuName
    cdnProfileName: cdnProfileName
    afdEndpointName: afdEndpointName
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
    routeRuleSets: [
      {
        id: profile.outputs.defaultRuleSets
      } 
    ]
    origins: origins
  }
}

output afdEndpointHostName string = profile.outputs.afdEndpointHostName
