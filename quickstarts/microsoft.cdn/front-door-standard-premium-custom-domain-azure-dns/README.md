---
description: This template creates a Front Door Standard/Premium including a custom domain on Azure DNS and Microsoft-managed certificate.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: front-door-standard-premium-custom-domain-azure-dns
languages:
- json
- bicep
---
# Front Door Standard/Premium with Azure DNS and custom domain

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-azure-dns/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-azure-dns/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-azure-dns/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-azure-dns/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-azure-dns/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-azure-dns/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/front-door-standard-premium-custom-domain-azure-dns/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-custom-domain-azure-dns%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-custom-domain-azure-dns%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Ffront-door-standard-premium-custom-domain-azure-dns%2Fazuredeploy.json)

This template deploys a Front Door Standard/Premium with custom domain managed through an Azure DNS zone, and Microsoft-managed TLS certificate.

## Sample overview and deployed resources

This sample template creates a Front Door profile with a custom domain, managed through an Azure DNS zone, and a Microsoft-managed TLS certificate. To keep the sample simple, Front Door is configured to direct traffic to a static website configured as an origin, but this could be [any origin supported by Front Door](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-origin).

The following resources are deployed as part of the solution:

### Front Door Standard/Premium
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the static website.
  - Note that you can use either the standard or premium Front Door SKU for this sample. By default, the standard SKU is used.
- Front Door custom domain.

### Azure DNS
- DNS zone for the custom domain.
- TXT record for validating the custom domain ownership.
- CNAME record to configure traffic to be sent to the Front Door endpoint.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

After you deploy the Azure Resource Manager template, you can then access the Front Door endpoint by using your custom domain name. If you access the hostname you should see a page saying _Welcome_. If you see a different error page, wait a few minutes and try again.

`Tags: Microsoft.Network/dnsZones, Microsoft.Network/dnsZones/CNAME, Microsoft.Network/dnsZones/TXT, Microsoft.Cdn/profiles, Microsoft.Cdn/profiles/afdEndpoints, Microsoft.Cdn/profiles/originGroups, Microsoft.Cdn/profiles/customDomains, Microsoft.Cdn/profiles/originGroups/origins, Microsoft.Cdn/profiles/afdEndpoints/routes`
