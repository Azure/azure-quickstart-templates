# Logic app that posts a message to a slack channel when an alert fires

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alert-to-slack-with-logic-app/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alert-to-slack-with-logic-app/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alert-to-slack-with-logic-app/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alert-to-slack-with-logic-app/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alert-to-slack-with-logic-app/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/alert-to-slack-with-logic-app/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Falert-to-slack-with-logic-app%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Falert-to-slack-with-logic-app%2Fazuredeploy.json)   [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Falert-to-slack-with-logic-app%2Fazuredeploy.json)

This template allows you to create a Logic app that has a webhook to be used from an Azure Alert. When the Alert is triggered, it will post a message to a slack channel that you specify. You need to have a slack account to use this template.

## Authorizing with Slack

After the template deployment has completed, there is a manual step that you must complete before the messages can be posted to the channel. You have to log in to your Slack account via the Logic apps UI in order to consent to give Logic apps access to your Slack:

1. Once the template has completed, navigate to the resource group you deployed it to.
2. Find the Logic app in the resource list, and click it.
3. Select the **Edit** button in the command bar.
4. You'll now see the *Logic app designer* with "Connections" as being the last step. 
5. Click "Connections". 
6. Sign in, and acknowledge that Logic apps can access your account. 
7. Click the Green checkmark at the bottom of the **Slack** card.
8. Click the Save button in the command bar.

## Call from your Alerts

To call this whenever your Alert fires, you need to paste in the webhook URI into the alert:

1. Once the template has completed, navigate to the resource group you deployed it to.
2. Under **Settings**, click on **Deployments**
3. Select the top deployment.
4. Click on **Outputs**. Copy the output called **WebHookURI**. 
5. Navigate to the alert you want to trigger the Logic app and select **Edit**.
6. Scroll to the bottom and paste in the **WebHook**. 
7. Click save.


