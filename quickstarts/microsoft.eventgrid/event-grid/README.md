# Create an Event Grid Custom Topic and Subscription on Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/101-event-grid/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventgrid%2Fevent-grid%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventgrid%2Fevent-grid%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventgrid%2Fevent-grid%2Fazuredeploy.json)

This template creates an Event Grid custom topic and webhook subscription on Azure.

This sample deploys an Azure Functions app with an [Event Grid trigger](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-grid-trigger) to act as a webhook. This is defined the `prereqs/prereq.azuredeploy.json` file. However, when you deploy your own Event Grid subscription you can use any valid webhook URL as long as it handles the [Event Grid subscription validation procedure](https://docs.microsoft.com/azure/event-grid/webhook-event-delivery).

> Note: The `prereq.azuredeploy.json` file uses a [template deployment script](https://docs.microsoft.com/azure/azure-resource-manager/templates/deployment-script-template) to help to determine the webhook URL of the function. The reason it does this is that the `listKeys` API on the function app doesn't work consistently - sometimes it won't return the Event Grid webhook key when the app has just been created. If the `listKeys` API is used directly within the ARM template then the deployment often fails. Instead, the deployment script polls the `listKeys` API, and once it sees a valid response it then provides that back to the temmplate so that it can construct the full webhook URL.

Template was authored by John Downs.

`Tags: eventgrid`
