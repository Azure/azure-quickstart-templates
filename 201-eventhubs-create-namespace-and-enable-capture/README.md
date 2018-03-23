# 201-eventhubs-create-namespace-and-enable-capture

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-eventhubs-create-namespace-and-enable-capture%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-eventhubs-create-namespace-and-enable-capture%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

For information about using this template, see [Create an Event Hubs namespace with Event Hub and enable Capture using an ARM template](http://azure.microsoft.com/documentation/articles/event-hubs-create-event-hub-and-enable-capture/)
Azure Event Hubs Capture enables you to automatically deliver the streaming data in your Event Hubs to a Blob storage of your choice with the added flexibility to specify a time or size interval of your choosing.
Setting up Capture is quick, there are no administrative costs to run it, and it scales automatically with your Event Hubs Throughput Units. Event Hubs Capture is the easiest way to load streaming data into Azure and allows you to focus on data processing rather than data capture. You will need to specify you existing storage resource id and your container to enable archiving to it.