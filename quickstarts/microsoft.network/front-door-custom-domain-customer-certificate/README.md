# Onboard a custom domain and customer-managed TLS certificate with Front Door

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/front-door-custom-domain-customer-certificate/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-custom-domain-customer-certificate%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Ffront-door-custom-domain-customer-certificate%2Fazuredeploy.json)   

This template creates a Front Door configuration with a single backend, onboards a custom domain, and then secures the custom domain with a customer-managed certificate.

Parameters for this template are:
- `frontDoorName` - Name of the Front Door (for example, `contoso`).
- `customDomainName` - Host name of the custom domain (for example, `contoso.com` or `www.contoso.com`).
- `certificateKeyVaultResourceId` - The fully qualified resource ID of the Key Vault that contains the custom domain's certificate.
- `certificateKeyVaultSecretName` - The name of the Key Vault secret that contains the custom domain's certificate.
- `certificateKeyVaultSecretVersion` - The version of the Key Vault secret that contains the custom domain's certificate.
- `backendAddress` - Host name of the backend (for example, `contoso-backend.azurewebsites.net`).

For the deployment of this template to succeed the specified custom domain will require a CNAME to the Front Door's default frontend host (for example, `contoso.azurefd.net`).

For example, for a Front Door instance named `contoso`, the default frontend host name would be `contoso.azurefd.net`. To add the custom domain `www.contoso.com`, create a DNS CNAME entry for `www.contoso.com` to `contoso.azurefd.net`. For more details, see [Tutorial: Add a custom domain to your Front Door](https://docs.microsoft.com/azure/frontdoor/front-door-custom-domain).

You also need to configure your Key Vault instance to work with Front Door. See [Prepare your Azure Key vault account and certificate](https://docs.microsoft.com/azure/frontdoor/front-door-custom-domain-https#prepare-your-azure-key-vault-account-and-certificate).
