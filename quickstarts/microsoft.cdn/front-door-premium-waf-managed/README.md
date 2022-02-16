# Front Door Premium (Preview) with Web Application Firewall and Microsoft-managed rule sets

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-waf-managed/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-waf-managed/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-waf-managed/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-waf-managed/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-waf-managed/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-waf-managed/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-premium-waf-managed/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-premium-waf-managed%2Fazuredeploy.json)  

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-premium-waf-managed%2Fazuredeploy.json)

This template deploys a Front Door Premium (Preview) with a Web Application Firewall (WAF) and Microsoft-managed rule sets.

## Sample overview and deployed resources

This sample template creates a Front Door profile with a WAF. To keep the sample simple, Front Door is configured to direct traffic to an Azure Storage static website configured as an origin, but this could be [any origin supported by Front Door](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-origin).

The following resources are deployed as part of the solution:

### Prerequisites
- Azure Storage with a static website, which acts as a simulated origin in this sample.

### Front Door Premium (Preview)
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the Azure Storage static website.
  - This sample must be deployed using the premium Front Door SKU, since this is required for managed rule sets in the WAF.
- Front Door WAF policy with two rule sets:
  - The [Microsoft default rule set](https://docs.microsoft.com/azure/web-application-firewall/afds/afds-overview#azure-managed-rule-sets), version 1.1.
  - The [Microsoft bot protection rule set](https://docs.microsoft.com/azure/web-application-firewall/afds/afds-overview#bot-protection-rule-set-preview), version 1.0.
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

## Notes

- Front Door Premium is currently in preview.
- Front Door Premium is not currently available in the US Government regions.
