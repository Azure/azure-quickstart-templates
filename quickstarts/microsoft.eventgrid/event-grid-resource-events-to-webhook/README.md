# Create Event Grid subscription for resource events

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid-resource-events-to-webhook/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid-resource-events-to-webhook/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid-resource-events-to-webhook/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid-resource-events-to-webhook/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid-resource-events-to-webhook/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventgrid/event-grid-resource-events-to-webhook/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventgrid%2Fevent-grid-resource-events-to-webhook%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventgrid%2Fevent-grid-resource-events-to-webhook%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventgrid%2Fevent-grid-resource-events-to-webhook%2Fazuredeploy.json) 

This template creates Event Grid subscription for either a resource group or Azure subscription. It sends the events to a WebHook. For information about deploying the template at the subscription level, see [Deploy resources to an Azure subscription](https://docs.microsoft.com/azure/azure-resource-manager/deploy-to-subscription).

You need a WebHook endpoint for receiving the events. If you have one, pass that URI as the `endpoint` parameter. If you do not have an existing endpoint, the template in the **prereqs** folder deploys a web app that displays the event messages. Deploy this template to your subscription. Pass that URI in the format `https://<your-site>/api/updates/` For more information, see [Create a message endpoint](https://docs.microsoft.com/azure/event-grid/custom-event-quickstart#create-a-message-endpoint).

`Tags: eventgrid`


