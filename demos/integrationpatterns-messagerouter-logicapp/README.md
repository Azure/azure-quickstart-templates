---
description: Shows how to set up a message router pattern using a logic App
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: integrationpatterns-messagerouter-logicapp
languages:
- json
---

# Integration Patterns - Message Router with Azure Logic Apps

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/integrationpatterns-messagerouter-logicapp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-logicapp%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-logicapp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fintegrationpatterns-messagerouter-logicapp%2Fazuredeploy.json)

## Solution overview and deployed resources

This template deploys a solution which shows to set up the [Message Router pattern](http://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRouter.html) using Azure Logic Apps. The logic app workflow receives a message through a web endpoint, and sends the message to a GitHub Gists endpoint with a filename, based on the contents of the message. The response returns the URL for the Gist file.

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
    "Address":"Wilhelminakade 175",
    "City":"Rotterdam",
    "Name":"Eldert Grootenboer"
}
```

`Tags: Logic Apps, Integration Patterns, Logic App, Message Router, LogicApps, IntegrationPatterns, Microsoft.Logic/workflows, Request, object, string, InitializeVariable, Response, Switch, Http, SetVariable`

