# Call Custom APIs Hosted on an Azure App Service Protected by Azure Active Directory Using Azure Logic Apps

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-logic-app-custom-api/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-logic-app-custom-api/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-logic-app-custom-api/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-logic-app-custom-api/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-logic-app-custom-api/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-logic-app-custom-api/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-custom-api%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-custom-api%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

Although Azure Logic Apps provides hundreds of connectors for various services, sometimes you want to call custom APIs that run your own code. Azure App Service provides one of the easiest and most scalable ways to host your own custom Web APIs. This template deploys a web app for your custom API that's secured by using Azure Active Directory (Azure AD) authentication.

For more information about how to use this template, see [Create custom APIs for Azure Logic Apps](https://docs.microsoft.com/azure/logic-apps/logic-apps-create-api-app).

## Azure AD application identities

*Before you can run this template*, you need to create two Azure AD application identities (IDs) – one for your logic app and one for your web app. Your logic app uses an application ID to authenticate against Azure AD. You authenticate calls to your web app by using a service principal (client ID and secret) that's associated with the Azure AD application ID for your logic app. Finally, you'll include the application IDs in your logic app definition.

You need to create an application ID for your logic app only *once* for your directory. For example, you can choose to use the same identity for all of your logic apps, although you can create unique identities per logic app if you want. You can complete this task either in the Azure portal or use PowerShell.

To learn how to create application IDs for your logic app and web app, see [Secure calls to custom APIs from logic app](https://docs.microsoft.com/azure/logic-apps/logic-apps-custom-api-authentication).

