# 201-eventhubs-create-namespace-and-enable-archive

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-eventhubs-create-event-hub-and-enable-archive%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

For information about using this template, see [Create an Event Hubs namespace with Event Hub and enable Archive using an ARM template](http://azure.microsoft.com/documentation/articles/event-hubs-create-event-hub-and-enable-archive/).
To enable archive on your Event Hub, you will have to specify a Storage Resource Id of your existing storage account and your exisiting container. The Archive will kick in based on your time or size interval and start archiving in the storage of your choice.