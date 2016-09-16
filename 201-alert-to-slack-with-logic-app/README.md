# Logic app that posts a message to a slack channel when an alert fires

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-slack-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-slack-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a Logic app that has a webhook to be used from an Azure Alert. When the Alert is triggered, it will post a message to a slack channel that you specify. You need to have a slack account to use this template.

## Authorizing with Slack

After the template deployment has completed, there is a manual step that you must complete before the messages can be posted to the channel. You have to log in to your Slack account via the Logic apps UI in order to consent to give Logic apps access to your Slack:

1. Once the template has completed, navigate to the resource group you deployed it to.
2. Find the Logic app (represented by a rocket icon) in the resource list, and click it.
3. Select the **Edit** button in the command bar.
4. You'll now see the *Logic app designer*, and you'll see a card with **Slack** in the title, and an **Change Connection** text.
5. Click it and choose "Create New"
6. Sign in, and acknowledge that Logic apps can access your account. 
7. Click the Green checkmark at the bottom fo the **Slack**card.
8. Click the Save button in the command bar.

## Call from your Alerts

To call this whenever your Alert fires, you need to paste in the webhook URI into the alert:

1. Once the template has completed, navigate to the resource group you deployed it to.
2. In the **Essentials** click on the **Last deployment** link. 
3. Select the top deployment.
4. This should show you the Outputs for the deployment. Copy the output called **WebHookURI**. 
5. Navigate to the alert you want to trigger the Logic app and select **Edit**.
6. Scroll to the bottom and paste in the **WebHook**. 
7. Click save.