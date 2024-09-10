---
description: This template references existing key-value configurations from an existing config store and uses retrieved values to set properties of the resources the template creates.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: app-configuration
languages:
- json
---
# App Configuration with VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration%2Fazuredeploy.json)

This template creates a config store and writes key-value configuration. It then references (reads) key-value configurations from the created config store from the Azure Resource Manager template. The retrieved values are used to set properties of other resources created by the template.

NOTE: The principal deploying the template must have contributor access to the App Configuration Store.

If you are new to App Configurations, see:

- [Azure App Configuration](https://azure.microsoft.com/services/app-configuration/).
- [Azure App Configuration Documentation](https://learn.microsoft.com/en-us/azure/azure-app-configuration/quickstart-resource-manager)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/allversions)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Azure4Student, AppConfiguration, Beginner, Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines`
