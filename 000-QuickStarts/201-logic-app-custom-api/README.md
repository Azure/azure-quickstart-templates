# Logic app calls into a Custom API hosted on App Service and protected by AAD

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-custom-api%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-custom-api%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Although Logic apps has a rich set of 40+ connectors for a variety of services, you may want to call into your own custom API that can run your own code. One of the easiest and most scalable ways to host your own custom Web API's is to use App Service. This template deploys a Web app for your Custom API and secures it using AAD auth.

For the full details of how to use this template see [this help topic](https://azure.microsoft.com/en-us/documentation/articles/app-service-logic-custom-hosted-api/).

# AAD Application identities

*Before you can run this template*, you’ll  need to create two Azure Active Directory applications – one for your Logic App and one for your Web App.  You’ll authenticate calls to your Web App using the service principal (client id and secret) associated with the AAD application for your Logic App. Finally, you'll include the application ID's in your Logic app definition. 

## Part 1: Setting up an Application identity for your Logic app

This is what the Logic app will use to authenticate against active directory. You only *need* to do this once for your directory; for example, can choose to use the same identity for all of your Logic apps, although you may also create unique ones per Logic app if you wish. You can either do this in the UI or use PowerShell.

1. Navigate to [Active directory in the Azure portal](https://manage.windowsazure.com/#Workspaces/ActiveDirectoryExtension/directory) and select the directory that you use for your Web App
2. Click the **Applications** tab
3. Click **Add** in the command bar at the bottom of the page
4. Give your identity a Name to use, click the next arrow
5. Put in a unique string formatted as a domain in the two text boxes, and click the checkmark
6. Click the **Configure** tab for this application
7. Copy the **Client ID**, this will be used in your Logic app (the **logicAppClientId** parameterg)
8. In the **Keys** section click **Select duration** and choose either 1 year or 2 years
9. Click the **Save** button at the bottom of the screen (you may have to wait a few seconds)
10. Now be sure to copy the key in the box. This will also be used in your Logic app (the **logicAppClientSecret** parameter)

## Part 2: Setting up an Application identity for your Web app

Second, you need to create an application for your Web app. This should be different from the application that is used for your Logic app. Do this by following the steps above in Part 1, but now for the **HomePage** and **IdentifierUris** use the actual https://**URL** of your Web app.

You will now use the **ClientId** from the **Configure** tab as the **webAppClientId** parameter.
