---
description: This template creates a Front Door Standard/Premium including a web application firewall with a custom rule.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: front-door-standard-premium-waf-custom
languages:
- json
- bicep
---
# Front Door Standard/Premium with WAF and custom rule

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-waf-custom/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-waf-custom/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-waf-custom/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-waf-custom/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-waf-custom/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-waf-custom/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-waf-custom/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-waf-custom%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-waf-custom%2Fazuredeploy.json)

This template deploys a Front Door Standard/Premium with a Web Application Firewall (WAF) and a custom rule set.

## Sample overview and deployed resources

This sample template creates a Front Door profile with a WAF. To keep the sample simple, Front Door is configured to direct traffic to a static website configured as an origin, but this could be [any origin supported by Front Door](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-origin).

The following resources are deployed as part of the solution:

### Front Door Standard/Premium
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the static website.
  - Note that you can use either the standard or premium Front Door SKU for this sample. Custom rules for the WAF are supported in either SKU (note that managed rule sets require the premium SKU though). By default, the standard SKU is used.
- Front Door WAF policy with a custom rule blocking requests from a defined set of IP address ranges.
  - In this sample, the IP address 198.51.100.100 and the range 203.0.113.0/24 are both blocked. These are within the [IANA IP address ranges reserved for documentation](https://tools.ietf.org/html/rfc5737).
- Front Door security policy to attach the WAF policy to the Front Door endpoint.

### Log Analytics
- Log Analytics workspace.
- Diagnostic settings to route the `FrontDoorWebApplicationFirewallLogs` to the Log Analytics workspace. This allows you to [tune the Front Door WAF](https://docs.microsoft.com/azure/web-application-firewall/afds/waf-front-door-tuning) based on your own traffic.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once you have deployed the Azure Resource Manager template, wait a few minutes before you attempt to access your Front Door endpoint to allow time for Front Door to propagate the settings throughout its network.

You can then access the Front Door endpoint. The hostname is emitted as an output from the deployment - the output is named `frontDoorEndpointHostName`. If you access the base hostname you should see a page saying _Welcome_. If you see a different error page, wait a few minutes and try again.

`Tags: Microsoft.Cdn/profiles, Microsoft.Cdn/profiles/afdEndpoints, Microsoft.Cdn/profiles/originGroups, Microsoft.Cdn/profiles/originGroups/origins, Microsoft.Cdn/profiles/afdEndpoints/routes, Microsoft.Network/FrontDoorWebApplicationFirewallPolicies, Microsoft.Cdn/profiles/securityPolicies, Microsoft.OperationalInsights/workspaces, Microsoft.Insights/diagnosticSettings`
