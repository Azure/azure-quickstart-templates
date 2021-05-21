# Simple deployment of UrlSigning action via rules engine for a CDN end point

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/cdn-with-ruleseengine-urlsigning/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/cdn-with-ruleseengine-urlsigning/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/cdn-with-ruleseengine-urlsigning/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/cdn-with-ruleseengine-urlsigning/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/cdn-with-ruleseengine-urlsigning/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cdn/cdn-with-ruleseengine-urlsigning/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Fcdn-with-ruleseengine-urlsigning%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cdn%2Fcdn-with-ruleseengine-urlsigning%2Fazuredeploy.json)    

This template creates a CDN Profile and a CDN Endpoint with a user specified origin and all of our most commonly used settings on CDN. This template also configures rules engine UrlSigning action for default and override parameters.

Before using the template, make sure to do the following:

1. Create a key vault in the same subscription or in a different subscription.
2. Define two secrets and set up secret values manually (at least 32 size)
3. References the two secrets in urlSigningKeys of the template (change subscriptionId, resourceGroupName, vaultName, secretName, secretVersion)
4. Make sure the keyvault is given "Get Permissions for Secret" access to "Microsoft.Azure.CDN" Principal.
