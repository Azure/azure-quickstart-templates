---
description: This template creates an Azure FrontDoor resource and connects an existing App Configuration store to the newly created Azure Front Door resource.
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

This template creates an Azure Front Door resource and connects it to an existing App Configuration store. It also configures Front Door child resources and assigns the App Configuration Data Reader role to the Front Door managed identity. 
**Note:** This template does not create an App Configuration store or modify its key-values.

If you are new to App Configurations, see:

- [Azure App Configuration](https://azure.microsoft.com/services/app-configuration/).
- [Azure App Configuration Documentation](https://docs.microsoft.com/azure/azure-app-configuration)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/allversions)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Prerequisites

Before you begin, ensure you have:

1. An active Azure subscription
1. An existing Azure App Configuration store. To create an App Configuration store using ARM template, see [App Configuration store](https://azure.microsoft.com/resources/templates/101-app-configuration-store/).
1. Permissions to create and manage Azure Front Door resources (Contributor or equivalent)
1. Permissions to assign roles on the App Configuration resource (Owner or User Access Administrator)
1. App Configuration Data Owner or App Configuration Data Reader role


Add the following key-values to you Azure App Configuration store:

|Key                        |Value                         |Label         |
|---------------------------|------------------------------|--------------|
|Message                    |Hello from App Configuration  | _(No label)_ |





`Tags: Azure4Student, AppConfiguration, Beginner, Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines`