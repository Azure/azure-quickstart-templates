# Logic app that sends a text message when an alert fires

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-alert-to-text-message-with-logic-app/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-alert-to-text-message-with-logic-app/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-alert-to-text-message-with-logic-app/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-alert-to-text-message-with-logic-app/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-alert-to-text-message-with-logic-app/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-alert-to-text-message-with-logic-app/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-text-message-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-alert-to-text-message-with-logic-app%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to create a Logic app that has a webhook to be used from an Azure Alert. When the Alert is triggered, it will send you a text message with the details of the alert. It uses the go.gl URL shortening service to include a link to the portal to see the resource. 

## Requirements

This template uses the Twilio service to send the text message. If you don't have an account yet, you can [sign up for a free trial](https://www.twilio.com/try-twilio) in just one minute. 

Once you have signed up for the free trial, you'll need to [verify the phone number that you want to send the alerts to](https://www.twilio.com/user/account/phone-numbers/verified).

Next, you will need to copy-and-paste the  **AccountSID** and the **AuthToken** from [the settings page](https://www.twilio.com/user/account/settings) into your template.   Finally, you need to copy-and-paste your [Twilio account phone number](https://www.twilio.com/user/account/phone-numbers/incoming) into the template as well. When you get the text message, this is the phone number it will appear *From*.

## Call from your Alerts

To call this whenever your Alert fires, you need to paste in the webhook URI into the alert:

1. Once the template has completed, navigate to the resource group you deployed it to.
2. In the **Essentials** click on the **Last deployment** link. 
3. Select the top deployment.
4. This should show you the Outputs for the deployment. Copy the output called **WebHookURI**. 
5. Navigate to the alert you want to trigger the Logic app and select **Edit**.
6. Scroll to the bottom and paste in the **WebHook**. 
7. Click save.

