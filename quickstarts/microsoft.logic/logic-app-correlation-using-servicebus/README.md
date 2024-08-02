---
description: Shows how to correlate messages over Azure Logic Apps using Azure Service Bus
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: logic-app-correlation-using-servicebus
languages:
- json
---

# Correlate messages over Azure Logic Apps using Azure Service Bus

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-correlation-using-servicebus/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-correlation-using-servicebus/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-correlation-using-servicebus/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-correlation-using-servicebus/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-correlation-using-servicebus/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-correlation-using-servicebus/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-correlation-using-servicebus%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-correlation-using-servicebus%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-correlation-using-servicebus%2Fazuredeploy.json)

## Solution overview and deployed resources

This template deploys a solution which shows how you can correlate messages over Azure Logic Apps using Azure Service Bus. The logic app workflow receives a message through a web endpoint, and sends the message to a MockBin endpoint, and returns the response to the original caller.

The following resources are deployed as part of the solution: **Logic app resource**

To test the logic app workflow, copy the endpoint URL from the Request trigger in the workflow. Send a POST request to the endpoint URL by using a tool that can send HTTP requests, for example: 

- [Visual Studio Code](https://code.visualstudio.com/download) with an extension from [Visual Studio Marketplace](https://marketplace.visualstudio.com/vscode)
- [PowerShell Invoke-RestMethod](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod)
- [Microsoft Edge - Network Console tool](https://learn.microsoft.com/microsoft-edge/devtools-guide-chromium/network-console/network-console-tool)
- [Bruno](https://www.usebruno.com/)
- [Curl](https://curl.se/)

> [!CAUTION]
> 
> For scenarios where you have sensitive data, such as credentials, secrets, access tokens, API keys,
> and other similar information, make sure to use a tool that protects your data with the necessary
> security features, works offline or locally, doesn't sync your data to the cloud, and doesn't require
> that you sign in to an online account. This way, you reduce the risk around exposing sensitive data to the public.

The message that you send should use the following format:

```json
{
    "Customer":"Eldert Grootenboer",
    "Product":"Surface Book 2",
    "Amount":"1"
}
```

`Tags: Azure Logic Apps, AzureLogicApps, Logic App, LogicApp, Logic Apps, LogicApps, ServiceBus, Service Bus, SessionId, Session Id, Correlation, Microsoft.Logic/workflows, ApiConnection, Http, Request, object, string, Foreach, InitializeVariable, ParseJson, integer, Response, Compose, Microsoft.ServiceBus/namespaces, Microsoft.Web/connections, Microsoft.ServiceBus/namespaces/AuthorizationRules, Microsoft.ServiceBus/namespaces/topics, Microsoft.ServiceBus/namespaces/topics/subscriptions, Microsoft.ServiceBus/namespaces/topics/subscriptions/rules`
