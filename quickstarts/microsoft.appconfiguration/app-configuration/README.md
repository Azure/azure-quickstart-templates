# Azure App Configuration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.appconfiguration/app-configuration/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.appconfiguration%2Fapp-configuration%2Fazuredeploy.json)

This template references (reads) existing key-value configurations from an existing config store from the Azure Resource Manager template. The retrieved values are used to set properties of the resources created by the template. This template does not create an App Configuration store or modify key-values in an App Configuration store. You must first create an App Configuration store, and then add key-values into the store using the Azure portal or Azure CLI. To create an App Configuration store by using ARM template, see [App Configuration store](https://azure.microsoft.com/resources/templates/101-app-configuration-store/). To go through the whole process, see [Quickstart: Automated VM deployment with App Configuration and Resource Manager template](https://docs.microsoft.com/azure/azure-app-configuration/quickstart-resource-manager).

To use this template, add the following key-values to your Azure App Configuration store:

|Key|Value|
|-|-|
|windowsOSVersion|2019-Datacenter|
|diskSizeGB|1023|

NOTE: The principal deploying the template must have contributor access to the App Configuration Store.

If you are new to App Configurations, see:

- [Azure App Configuration](https://azure.microsoft.com/services/app-configuration/).
- [Azure App Configuration Documentation](https://docs.microsoft.com/azure/azure-app-configuration/
)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/allversions)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Azure4Student, AppConfiguration, Beginner`
