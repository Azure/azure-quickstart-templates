---
description: This template sets up an 'Azure Native New Relic Service' to monitor resources in your Azure subscription.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: newrelic
languages:
- json
---
# Create a Azure Native New Relic Resource

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/newrelic.observability/newrelic/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/newrelic.observability/newrelic/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/newrelic.observability/newrelic/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/newrelic.observability/newrelic/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/newrelic.observability/newrelic/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/newrelic.observability/newrelic/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fnewrelic.observability%2Fnewrelic%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fnewrelic.observability%2Fnewrelic%2FcreateUiDefinition.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fnewrelic.observability%2Fnewrelic%2Fazuredeploy.json)

This template creates an [Azure Native New Relic Service](https://aka.ms/azurenativenewrelic) resource to monitor resources in your Azure subscription. It has the following capabilities:

- Create and manage a New Relic account for your cloud observability needs. 

- Send subscription activity logs and Azure resource logs for [all defined sources](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-logs/logs-index). 

- Pull Azure monitor platform metrics for all resources, into New Relic. 

- Bulk install New Relic agent extension to monitor your virtual machines and App Services.

Learn more about Azure Native New Relic Service [here](https://aka.ms/azurenativenewrelicdocs). 

`Tags: NewRelic.Observability/monitors`
