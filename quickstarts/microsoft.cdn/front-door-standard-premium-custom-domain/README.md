---
description: This template creates a Front Door Standard/Premium including a custom domain and Microsoft-managed certificate.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: front-door-standard-premium-custom-domain
languages:
- bicep
- json
---
# Front Door Standard/Premium with custom domain

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-custom-domain%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-custom-domain%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-custom-domain%2Fazuredeploy.json)

This template deploys a Front Door Standard/Premium with a custom domain and Microsoft-managed TLS certificate.

## Sample overview and deployed resources

This sample template creates a Front Door profile with a custom domain and a Microsoft-managed TLS certificate. To keep the sample simple, Front Door is configured to direct traffic to a static website configured as an origin, but this could be [any origin supported by Front Door](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-origin).

The following resources are deployed as part of the solution:

### Front Door Standard/Premium
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the static website.
  - Note that you can use either the standard or premium Front Door SKU for this sample. By default, the standard SKU is used.
- Front Door custom domain.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

After you deploy the Azure Resource Manager template, you need to validate your ownership of the custom domain by updating your DNS server. You must create a TXT record with the name specified in the `customDomainValidationDnsTxtRecordName` deployment output, and use the value specified in the `customDomainValidationDnsTxtRecordValue` deployment output. You must do the validation before the time specified in the `customDomainValidationExpiry` deployment output.

Front Door validates your domin ownership and updates the status automatically. You can monitor the validation process, or trigger an immediate validation, in the domain configuration in the Azure portal.

Next, you should configure your DNS server with a CNAME record to direct the traffic to Front Door. You must create a CNAME record at the host name you specified in the `customDomainName` deployment parameter, and use the value specified in the `frontDoorEndpointHostName` deployment output.

You can then access the Front Door endpoint by using your custom domain name. If you access the hostname you should see a page saying _Welcome_. If you see a different error page, wait a few minutes and try again.

`Tags: Microsoft.Cdn/profiles, Microsoft.Cdn/profiles/afdEndpoints, Microsoft.Cdn/profiles/originGroups, Microsoft.Cdn/profiles/customDomains, Microsoft.Cdn/profiles/originGroups/origins, Microsoft.Cdn/profiles/afdEndpoints/routes`
