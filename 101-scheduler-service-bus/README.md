# Create a Service Bus Queue and Azure Scheduler Job on Azure

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-scheduler-service-bus/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-scheduler-service-bus/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-scheduler-service-bus/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-scheduler-service-bus/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-scheduler-service-bus/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-scheduler-service-bus/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-scheduler-service-bus%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-scheduler-service-bus%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

The template is intended to illustrate how an ARM template can completely manage the provisioning of an automatic process to post a queue message to a Service Bus queue, without any application code or PowerShell coding required.

This template creates:
 * An Service Bus namespace, queue, and write-only SAS policy;
 * An Azure Scheduler job collection and job that will post a message into the Service Bus queue at a regular interval. By default, this is every minute.

Template originally authored by John Downs.

`Tags: servicebus scheduler`

