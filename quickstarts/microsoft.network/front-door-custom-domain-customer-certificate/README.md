# Onboard a custom domain and customer-managed TLS certificate with Front Door

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-custom-domain%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-custom-domain%2Fazuredeploy.json)

This template Creates a Front Door configuration with a single backend, onboards a custom domain with a path match '/*' for default frontend host and custom domain, and then secures custom domain with a customer-managed certificate.

Parameters for this template are:
- `frontDoorName` - Name of the frontdoor (ex: contoso)
- `customDomainName` - FQDN name of the custom domain (ex: www.contoso.com)
- `certificateKeyVaultResourceId` - The fully qualified resource ID of the Key Vault that contains the custom domain's certificate.
- `certificateKeyVaultSecretName` - The name of the Key Vault secret that contains the custom domain's certificate.
- `certificateKeyVaultSecretVersion` - The version of the Key Vault secret that contains the custom domain's certificate.
- `backendAddress` - FQDN of the backend (ex: www.contoso-backend.azurewebsites.com)

For the deployment of this template to succeed the specified custom domain will require a CNAME to the Front Door's default frontend host (say `contoso.azurefd.net`).

For example, for a Front DOor instance named `contoso`, the default frontend host name would be `contoso.azurefd.net`. To add a custom domain `www.contoso.com`, CNAME `www.contoso.com` to `contoso.azurefd.net`.

For more details, see [Tutorial: Add a custom domain to your Front Door](https://docs.microsoft.com/azure/frontdoor/front-door-custom-domain).
