# Front Door Standard/Premium (Preview) with custom domain and customer-managed TLS certificate

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-custom-domain-customer-certificate/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-custom-domain-customer-certificate/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-custom-domain-customer-certificate/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-custom-domain-customer-certificate/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-custom-domain-customer-certificate/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-custom-domain-customer-certificate/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-standard-premium-custom-domain-customer-certificate/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-custom-domain-customer-certificate%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-custom-domain-customer-certificate%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-standard-premium-custom-domain-customer-certificate%2Fazuredeploy.json)

This template deploys a Front Door Standard/Premium (Preview) with a custom domain and customer-managed TLS certificate.

## Sample overview and deployed resources

This sample template creates a Front Door profile with a custom domain and a customer-managed TLS certificate. To keep the sample simple, Front Door is configured to direct traffic to a static website configured as an origin, but this could be [any origin supported by Front Door](https://docs.microsoft.com/azure/frontdoor/standard-premium/concept-origin).

The following resources are deployed as part of the solution:

### Front Door Standard/Premium (Preview)
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the static website.
  - Note that you can use either the standard or premium Front Door SKU for this sample. By default, the standard SKU is used.
- Front Door secret, which refers to a Key Vault secret containing the TLS certificate to use.
- Front Door custom domain, which refers to the Front Door secret.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once you have deployed the Azure Resource Manager template, you need to validate the custom domain. TODO

Next, configure CNAME forwarding TODO

You can then access the Front Door endpoint by using your custom domain name. If you access the base hostname you should see a page saying _Welcome_. If you see a different error page, wait a few minutes and try again.

## Notes

TODO granting Key Vault access

- Front Door Standard/Premium is currently in preview.
- Front Door Standard/Premium is not currently available in the US Government regions.
