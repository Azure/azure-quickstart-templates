---
description: This template creates a new Azure FrontDoor cdn profile. Create WAF with custom and managed rules, cdn routes, origin and groups with their association with WAF and routes, configures custom domains, create event hub and diagnostic settings for sending CDN access logs using event hub.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: modules-microsoft.cdn-azure-frontdoor-cdn-profile-1.0
languages:
- json
- bicep
---
# FrontDoor CDN with WAF, Domains and Logs to EventHub

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.cdn/azure-frontdoor-cdn-profile/1.0/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.cdn/azure-frontdoor-cdn-profile/1.0/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.cdn/azure-frontdoor-cdn-profile/1.0/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.cdn/azure-frontdoor-cdn-profile/1.0/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.cdn/azure-frontdoor-cdn-profile/1.0/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.cdn/azure-frontdoor-cdn-profile/1.0/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/modules/microsoft.cdn/azure-frontdoor-cdn-profile/1.0/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmicrosoft.cdn%2Fazure-frontdoor-cdn-profile%2F1.0%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmicrosoft.cdn%2Fazure-frontdoor-cdn-profile%2F1.0%2Fazuredeploy.json)   

A sample module to create Azure FrontDoor CDN profile. 

1. Create Azure FrontDoor Standard/Premium CDN Profile
2. Create routes and associate them with domain, origin and ruleset(s).
3. Create ruleSets. For example, with ModifyResponseHeader, RouteConfigurationOverride (Cache Override)
4. Create waf with Custom rules in Block Mode. (In this example, blocking all method except GET, OPTIONS and HEAD)
5. Create waf with managed rules in Log Mode.
6. Attach waf as security policy to endpoint
7. Dynamically create custom domain and their association
8. Attach AFD provided managed certificate for TLS. 
9. Dynamically create Origin and Origin Group using array and their attachment with Routes, WAF policy etc.
10. Create event namespace and hub
11. Create Diagnostic Settings using eventHub for sending Azure FrontDoor CDN logs to event Hub.

## Parameters


| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| skuName | string | No | Name of Azure CDN SKU. One of `Premium_AzureFrontDoor` or `Standard_AzureFrontDoor` ( default = `Premium_AzureFrontDoor` ) |
| envName | string | Yes | Environment Name. A user defined value. Example: `stg`, `prod` |
| customDomains | array | Yes | Custom domain for CDN profile |
| origins | array | Yes | List of Origins to send request for Cache Fill |
| afdEndpointName | string | No | Name of the AFD Endpoint ( default = `afd-cdn-${envName}` ) |
| enableAfdEndpoint | bool | No | Control flag for enabling or disabling CDN profile ( default = `true` ) |
| cdnProfileName | string | No | Name of the AFD CDN Profile ( default = `afd-cdn-${envName}-profile` ) |
| cdnProfileTags | object | No | Tags to be attached with resources ( default = `{envName: ${envName}}` ) |
| eventHubName | string | No | EventHub instance name ( default = `eventhub-${uniqueString(resourceGroup().id)}` ) |
| eventHubNamespace | string | No | EventHub namespace name ( default = `'${eventHubName}-ns'` ) |
| eventHubLocation | string | No | Region to deploy EventHub ( default = `resourceGroup().location` ) |
| wafPolicyMode | string | No | Policy Mode for WAF. One of `Detection` or `Prevention` ( default = `Prevention` ) |
| wafPolicyName | string | No | Name of WAF Policy to be created ( default = `FrontDoorCdn${envName}WAF` ) |
| enableRequestBodyCheck | bool | No | Enable request body inspection ( default = `false` ) |
| enableWAFPolicy | bool | No | Control flag for enabling or disabling WAF security policy ( default = `true` ) |
| wafBlockResponseBody | string | No | Response body to be returned by WAF on request block ( default = `Access Denied by Firewall.` ) |
| wafBlockResponseCode | int | No | Response code to be returned by WAF on request block ( default = `403` ) |


### Sample Schema for Arrays and Objects Parameters

**cdnProfileTags**:

```bash
{
 "supportGroup": "support@example.com"
 "env": "test"
}
```

**customDomains**:

```bash
[
 {
   "hostname": "static.example.com"
 }
]
```

**origins**:

```bash
[
 {
   "hostname": "static-src.example.com",
   "originGroupName": "static-src-origin-group",
   "patternsToMatch": [
     "/*"
   ],
   "enabledState": true
 } 
]
```

where, 

`hostname`: Origin Hostname  
`originGroupName`: Name of origin group  
`patternsToMatch`: Array of patterns to match for path to send request to origin for a request path  
`enabledState`: Enable or disable origin  

## Output

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| afdEndpointHostName | string | Azure FrontDoor CDN AFD Endpoint Name |


## Directory Structure

```bash
.
├── README.md
├── azuredeploy.parameters.json
├── images
│   └── deployment.png
├── main.bicep
├── metadata.json
└── modules
    ├── diagnosticsettings.bicep
    ├── eventhub.bicep
    ├── profile.bicep
    ├── routes.bicep
    ├── rulesets.bicep
    └── waf.bicep
```

1. Directory `modules` contains base bicep files:
   1. `diagnosticsettings.bicep`: Create diagnostic settings to send Azure cdn access logs to event hub.
   2. `eventhub.bicep`: Create eventhub namespace and eventhub instance.
   3. `profile.bicep`: Invoke modules to create cdn profile, rule sets, diagnostic settings and attach waf security policy.
   4. `routes.bicep`: Create cdn routes for profile.
   5. `rulesets.bicep`: Create rule sets that are required by CDN Profile.
   6. `waf.bicep`: Create WAF with Managed and Custom rules that needs to be attached to CDN Profile as Security Policy.
2. `main.bicep` provides an abstracted view to a user for creating CDN profile and waf attachment.

`Tags: Microsoft.Cdn/profiles, Microsoft.Cdn/profiles/afdEndpoints, Microsoft.Cdn/profiles/afdendpoints/routes, Microsoft.Cdn/profiles/customdomains, Microsoft.Cdn/profiles/originGroups, Microsoft.Cdn/profiles/originGroups/origins, Microsoft.Cdn/profiles/rulesets, Microsoft.Cdn/profiles/rulesets/rules, Microsoft.Cdn/profiles/securitypolicies, Microsoft.EventHub/namespaces, Microsoft.EventHub/namespaces/AuthorizationRules, Microsoft.EventHub/namespaces/eventhubs, Microsoft.EventHub/namespaces/eventhubs/consumergroups, Microsoft.EventHub/namespaces/networkRuleSets, Microsoft.Insights/diagnosticSettings, Microsoft.Network/frontdoorwebapplicationfirewallpolicies, Premium_AzureFrontDoor, cdn`