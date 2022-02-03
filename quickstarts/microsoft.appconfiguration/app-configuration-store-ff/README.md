# Azure App Configuration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-ff/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-ff/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-ff/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-ff/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-ff/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-store-ff/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-store-ff%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-store-ff%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-store-ff%2Fazuredeploy.json)

This template creates an Azure App Configuration store, then creates a feature flag inside the new store.

Feature flag belongs to `keyValues` resouce type. To be a feature flag, the key of `keyValues` resouce requires prefix `.appconfig.featureflag/`. However, `/` is forbidden in resource's name. `~2F` is used to espace the forward slash character. For more information about the `keyValues` resrouce's name, refer to the `Tip` section of [this tutorial](https://docs.microsoft.com/azure/azure-app-configuration/quickstart-resource-manager).

If you're new to App Configuration, see:

- [Azure App Configuration](https://azure.microsoft.com/services/app-configuration/)
- [Azure App Configuration documentation](https://docs.microsoft.com/azure/azure-app-configuration/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/allversions)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create an Azure App Configuration store by using an ARM template](https://docs.microsoft.com/azure/azure-app-configuration/quickstart-resource-manager)

`Tags: Azure4Student, AppConfiguration, Beginner`
