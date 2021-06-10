# Azure Automation create account template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/101-automation/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/101-automation/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/101-automation/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/101-automation/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/101-automation/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/101-automation/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2F101-automation%2Fazuredeploy.json)
[![Deploy to Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2F101-automation%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2F101-automation%2Fazuredeploy.json)

This template demonstrates the creation of an Azure Automation account and links it
to a new or existing Azure Monitor Log Analytics workspace that you specify. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/automation/quickstart-create-automation-account-template) article.

## Is it acceptable to link directly to PowerShell Gallery in Azure-Quickstart-Templates?

The expected workflow from any public gallery is to download/save an artifact,
review the source code and test it to verify functionality,
and then publish it to a private, trusted feed for usage.
However, since module authors releasing to PowerShell Gallery increment the version number
when changes are made,
if template authors would like to validate and test *specific versions* of modules
in the gallery and use *static links* to those artifacts,
those artifacts can be expected to remain unchanged.
**This does not change the operational best practice behavior of reviewing, validating, and testing
all code artifacts including ARM templates, PowerShell scripts, and DSC resources,
before production deployment.**
