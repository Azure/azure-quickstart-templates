# Logic app that adds an item to a queue when an alert fires

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-queue-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-queue-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a Logic app that has a webhook. When the Logic app is triggered, it will add the payload you pass to an Azure Storage queue that you specify. You can add this webhook to an Azure Alert and then whenever the Alert fires, you'll get that item in the queue.

## Call from your Alerts

To call this whenever your Alert fires, you need to paste in the webhook URI into the alert:

1. Once the template has completed, navigate to the resource group you deployed it to.
2. In the **Essentials** click on the **Last deployment** link. 
3. Select the top deployment.
4. This should show you the Outputs for the deployment. Copy the output called **WebHookURI**. 
5. Navigate to the alert you want to trigger the Logic app and select **Edit**.
6. Scroll to the bottom and paste in the **WebHook**. 
7. Click save.
