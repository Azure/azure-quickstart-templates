---
description: This template enables you to deploy a Time Series Insights environment that is configured to consume events from an Event Hub.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: timeseriesinsights-environment-with-eventhub
languages:
- json
---
# Create an Environment with an Event Hub Event Source

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-with-eventhub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-with-eventhub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-with-eventhub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-with-eventhub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-with-eventhub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.timeseriesinsights/timeseriesinsights-environment-with-eventhub/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.timeseriesinsights%2Ftimeseriesinsights-environment-with-eventhub%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.timeseriesinsights%2Ftimeseriesinsights-environment-with-eventhub%2Fazuredeploy.json)

This template creates a standard (S1 or S2 sku) Time Series Insights environment, a child event source configured to consume events from an Event Hub, and access policies that grant access to the environment's data. For more information, go to: <https://docs.microsoft.com/azure/time-series-insights/>.

`Tags: Microsoft.EventHub/namespaces, eventhubs, authorizationRules, consumergroups, Microsoft.TimeSeriesInsights/environments, eventsources, Microsoft.TimeSeriesInsights/environments/accessPolicies`
