# Create a Service Bus Queue and Azure Scheduler Job on Azure
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-scheduler-service-bus%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-scheduler-service-bus%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates:
 * An Service Bus namespace, queue, and write-only SAS policy;
 * An Azure Scheduler job collection and job that will post a message into the Service Bus queue every 1 minute.

Template originally authored by John Downs.

`Tags: servicebus scheduler`
