# Create Azure Blob Storage account with Event Grid subscription
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-event-grid-subscription-and-blob%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-event-grid-subscription-and-blob%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates an Azure Storage Account and then creates an Event Grid subscription to that storage account.

You need a WebHook endpoint for receiving the events. If you have one, pass that URI as the `endpoint` parameter. If you do not have an existing endpoint, the template in the **prereqs** folder deploys a web app that displays the event messages. Deploy this template to your subscription. Pass that URI in the format `https://<your-site>/api/updates/` For more information, see [Create a message endpoint](https://docs.microsoft.com/azure/event-grid/custom-event-quickstart#create-a-message-endpoint).

`Tags: eventgrid`
