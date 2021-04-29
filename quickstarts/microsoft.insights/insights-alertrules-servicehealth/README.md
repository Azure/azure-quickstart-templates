# Create an Azure service alert for a resource group 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/insights-alertrules-servicehealth/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/insights-alertrules-servicehealth/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/insights-alertrules-servicehealth/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/insights-alertrules-servicehealth/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/insights-alertrules-servicehealth/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/insights-alertrules-servicehealth/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Finsights-alertrules-servicehealth%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Finsights-alertrules-servicehealth%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Finsights-alertrules-servicehealth%2Fazuredeploy.json)  

This template allows you to add an Azure service alert to a resource group. These are alerts about incidents affecting Azure services that may impact resources in the resource group. Such alerts are managed through the Azure Resource Manager Insights API.

There are 3 types of alert:
* Active
* InProgress
* Resolved
Each of them must be added separately.

It is an ARM template implementation of the [Create or update an alert rule](https://msdn.microsoft.com/en-us/library/azure/dn933805.aspx) operation in the Azure Resource Manager Insights API. The creation of these alerts in C# is described in this [post](https://code.msdn.microsoft.com/How-To-Setup-Email-Alerts-c26cdc55) by Matt Loflin.
