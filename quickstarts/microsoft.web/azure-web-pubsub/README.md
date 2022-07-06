---
description: Azure Web PubSub Service helps you build real-time messaging web applications using WebSockets and the publish-subscribe pattern. This uses Bicep language to create and configure a Web PubSub resource. You can use this template to conveniently deploy Web PubSub for a tutorial or testing, or as a building block for more complex deployments with Web PubSub.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-web-pubsub
languages:
- json
- bicep
---
# Create Azure Web PubSub by using Bicep

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/azure-web-pubsub/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fazure-web-pubsub%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fazure-web-pubsub%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fazure-web-pubsub%2Fazuredeploy.json)

This Bicep template deploys a simple instance of Azure Web PubSub service. <!--For more information about how to use this template, see [Quickstart: Create an Azure Web PubSub service by using a Bicep file]( insert link here as soon as it is available )-->

## Prerequisites

If you don't have an [Azure subscription](/azure/guides/developer/azure-developer-guide#understanding-accounts-subscriptions-and-billing), create an [Azure free account](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) before you begin.

## Resources created in this template

- `Microsoft.SignalRService/webPubSub@2021-10-01`
  - Defaults: Free tier, 1 unit
  - Live trace: disabled
  - Connectivity and messaging logs: enabled
  - TLS clientCertEnabled: disabled

`Tags: Web PubSub, Bicep, real-time messaging, publish-subscribe, Microsoft.SignalRService/webPubSub, None`
