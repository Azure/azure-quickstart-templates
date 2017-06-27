# 201-eventhubs-create-namespace-and-enable-archive

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-eventhubs-create-namespace-and-enable-archive%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

For information about using this template, see [Create an Event Hubs namespace with Event Hub and enable Archive using an ARM template](http://azure.microsoft.com/documentation/articles/event-hubs-create-event-hub-and-enable-archive/)
Azure Event Hubs Archive enables you to automatically deliver the streaming data in your Event Hubs to a Blob storage of your choice with the added flexibility to specify a time or size interval of your choosing.
Setting up Archive is quick, there are no administrative costs to run it, and it scales automatically with your Event Hubs Throughput Units. Event Hubs Archive is the easiest way to load streaming data into Azure and allows you to focus on data processing rather than data capture. You will need to specify you existing storage resource id and your container to enable archiving to it.