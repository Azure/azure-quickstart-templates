---
description: The template connects Azure App Configuration store to a newly created Azure Front Door resource. The template creates a Front Door profile, a Front Door endpoint with App Configuration as origin, and sets up a route with rules that control which requests pass through Azure Front Door to App Configuration.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: app-configuration-afd
languages:
- json
---
# App Configuration integration with Azure Front Door

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-afd/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-afd/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-afd/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-afd/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-afd/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-afd/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration-afd/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-afd%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration-afd%2Fazuredeploy.json)

This template creates an Azure App Configuration store if it doesn't exist, an Azure Front Door resource and connects it to the App Configuration store. It also configures Front Door child resources and assigns the App Configuration Data Reader role to the Front Door managed identity.

If you are new to App Configurations, see:

- [Azure App Configuration](https://azure.microsoft.com/services/app-configuration/).
- [Azure App Configuration Documentation](https://docs.microsoft.com/azure/azure-app-configuration).
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/allversions)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Prerequisites

Before you begin, ensure you have:

1. An active Azure subscription.
1. An existing Azure App Configuration store.
1. Permissions to create and manage Azure Front Door resources (Contributor or equivalent).
1. Permissions to assign roles on the App Configuration resource (Owner or User Access Administrator).
1. App Configuration Data Owner.
1. Basic understanding of [CDN and content delivery concepts](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview).
1. [Hyperscale configuration delivery for client applications](https://aka.ms/appconfig/azurefrontdoor).

Add the following key-value to your Azure App Configuration store:

|Key                        |Value                         |Label         |
|---------------------------|------------------------------|--------------|
|Message                    |Hello from App Configuration  | _(No label)_ |




`Tags: Azure4Student, AppConfiguration, Beginner, Microsoft.AppConfiguration/configurationStores, Microsoft.AppConfiguration/configurationStores/keyValues, Microsoft.Cdn/profiles, Microsoft.Cdn/profiles/afdEndpoints, Microsoft.Cdn/profiles/originGroups, Microsoft.Cdn/profiles/originGroups/origins, Microsoft.Cdn/profiles/afdEndpoints/routes`