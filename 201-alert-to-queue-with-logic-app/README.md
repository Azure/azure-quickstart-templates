# Logic app that adds an item to a queue when an alert fires

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fstepsic-microsoft-com%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-queue-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fstepsic-microsoft-com%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-queue-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a Logic app that has a webhook. When the Logic app is triggered, it will add the payload you pass to an Azure Storage queue that you specify. You can add this webhook to an Azure Alert and then whenever the Alert fires, you'll get that item in the queue.