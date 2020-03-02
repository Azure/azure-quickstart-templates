# Azure App Configuration

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-app-configuration/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-app-configuration/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-app-configuration/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-app-configuration/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-app-configuration/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-app-configuration/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-configuration%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-configuration%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template references (reads) existing key-value configurations from an existing config store from the Azure Resource Manager template. The retrieved values are used to set properties of the resources created by the template. This template does not create an App Configuration store or modify key-values in an App Configuration store. You must first create an App Configuration store, and then add key-values into the store using the Azure portal or Azure CLI.

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
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Azure4Student, AppConfiguration, Beginner`
