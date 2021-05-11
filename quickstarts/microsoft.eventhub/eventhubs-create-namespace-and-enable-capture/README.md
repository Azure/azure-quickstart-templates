# Create Event Hub - namespace, eventhub with capture enabled

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventhub/eventhubs-create-namespace-and-enable-capture/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventhub/eventhubs-create-namespace-and-enable-capture/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventhub/eventhubs-create-namespace-and-enable-capture/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventhub/eventhubs-create-namespace-and-enable-capture/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventhub/eventhubs-create-namespace-and-enable-capture/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.eventhub/eventhubs-create-namespace-and-enable-capture/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventhub%2Feventhubs-create-namespace-and-enable-capture%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventhub%2Feventhubs-create-namespace-and-enable-capture%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.eventhub%2Feventhubs-create-namespace-and-enable-capture%2Fazuredeploy.json)

For information about using this template, see [Create an Event Hubs namespace with Event Hub and enable Capture using an ARM template](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-resource-manager-namespace-event-hub-enable-capture)
Azure Event Hubs Capture enables you to automatically deliver the streaming data in your Event Hubs to a Blob storage of your choice with the added flexibility to specify a time or size interval of your choosing.
Setting up Capture is quick, there are no administrative costs to run it, and it scales automatically with your Event Hubs Throughput Units. Event Hubs Capture is the easiest way to load streaming data into Azure and allows you to focus on data processing rather than data capture. You will need to specify you existing storage resource id and your container to enable archiving to it.
