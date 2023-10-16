---
description: This template creates a new Datadog - An Azure Native ISV Service resource and a Datadog organization to monitor resources in your subscription.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: datadog
languages:
- bicep
- json
---
# Create a new Datadog Organization

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datadog/datadog/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datadog/datadog/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datadog/datadog/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datadog/datadog/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datadog/datadog/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datadog/datadog/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datadog/datadog/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datadog%2Fdatadog%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datadog%2Fdatadog%2FcreateUiDefinition.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datadog%2Fdatadog%2Fazuredeploy.json)

This template deploys a new Datadog – An Azure Native ISV Service resource and creates a new organization in Datadog’s US3 site to monitor resources in your Azure subscription. It has the following capabilities:

- Collecting metrics for all resources, except Virtual Machines, Virtual Machine Scale Sets and App Service Plans.

- Sending subscription activity logs and Azure resource logs for [all defined sources](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/resource-logs-categories?WT.mc_id=Portal-Azure_Marketplace_Datadog).

- Muting the monitor for expected Azure VM Shutdowns. Learn more about Datadog – An Azure Native ISV Service [here](https://aka.ms/ANIS/Datadog/Docs).

`Tags: Microsoft.Datadog/monitors`
