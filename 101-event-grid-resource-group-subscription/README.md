# Create an Event Grid Custom Topic and Subscription on Azure
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-event-grid-resource-group-subscription%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-event-grid-resource-group-subscription%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates an Azure Event Grid subscription to a resource group. It uses a WebHook to receive the events. Deploy the template to a resource group to subscribe to events for that resource group.

The parameters file includes an endpoint URL, but this URL is for not intended for your use. You should create your own endpoint and use that URL. To create a site that collects event messages, see [Create a message endpoint](https://docs.microsoft.com/azure/event-grid/custom-event-quickstart#create-a-message-endpoint). 

`Tags: eventgrid`
