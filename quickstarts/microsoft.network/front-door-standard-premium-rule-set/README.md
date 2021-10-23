# Front Door Standard/Premium (Preview) with rule set

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-rule-set/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-rule-set/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-rule-set/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-rule-set/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-rule-set/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-rule-set/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-rule-set/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-rule-set%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-rule-set%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-rule-set%2Fazuredeploy.json)

This template deploys a Front Door Standard/Premium (Preview) with a rule set.

## Sample overview and deployed resources

This sample template creates a Front Door profile with a rule set. To keep the sample simple, Front Door is configured to direct traffic to a static website configured as an origin, but this could be [any origin supported by Front Door](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-origin).

The rule set is configured to identify any incoming requests that go to a path beginning with `/secure/`, and to redirect these requests to `https://microsoft.com` using an HTTP 307 temporary redirect. You can easily replace this rule with your own by reviewing the documentation about [rule set match conditions](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-rule-set-match-conditions) and [actions](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-rule-set-actions).

The following resources are deployed as part of the solution:

### Front Door Standard/Premium (Preview)
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the static website.
  - Note that you can use either the standard or premium Front Door SKU for this sample. By default, the standard SKU is used.
- Front Door rule set with a single rule and the following configuration:
  - Match condition:
    - _If: request path begins with `secure/` (transform to lowercase)_
  - Action:
    - _Then: URL redirect (HTTP 307) to `https://microsoft.com`_

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once you have deployed the Azure Resource Manager template, wait a few minutes before you attempt to access your Front Door endpoint to allow time for Front Door to propagate the settings throughout its network.

You can then access the Front Door endpoint. The hostname is emitted as an output from the deployment - the output is named `frontDoorEndpointHostName`. If you access the base hostname you should see a page saying _Welcome_. If you see a different error page, wait a few minutes and try again.

To test the rule set, try appending `/secure/123` to the URL. You should get redirected to the Microsoft website.

## Notes

- Front Door Standard/Premium is currently in preview.
- Front Door Standard/Premium is not currently available in the US Government regions.
