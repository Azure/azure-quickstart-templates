# Azure Web Chat Bot 

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-chatbot%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a><a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-chatbot2019%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a **Web App Echo Bot**, using the F0 Free Tear. 

###Prequesites:

#### App Registration

App Registration is necessary to make your ChatBot work. To create your own App ID, follow the steps below.

1. Sign in to the [Azure Portal](https://portal.azure.com/) using your Azure Student Account.

2. Go to **All Services** and search for **app registrations**. 
3. Go to the app registrations blade and click **New registration** in the action bar at the top.
4. Enter a display name for the application registration in the Name field and select the supported account types. The name does not have to match the bot ID.
>**Important**  
>
>In the Supported account types, select the Accounts in any organizational directory and personal Microsoft accounts (e.g. Skype, Xbox, Outlook.com) radio button. If any of the other options are selected, **bot creation will fail.**

5. Click **Register**. After a few moments, the newly created app registration should open a blade. Copy the Application (client) ID in the Overview blade and paste it into the App ID field. (That is a parameter need it in order to deploy our ARM Template)

Now we gonna need to generate a secret for the App Registration:
6. Click on **Certificates & secrets** in the left navigation column of your app registration’s blade.
7. In that blade, click the **New client secret** button. In the dialog that pops up, enter an optional description for the secret and select **Never** from the Expires radio button group.

>**Note**

>The secret will only be visible while on this blade, and you won't be able to retrieve it after you leave that page. Be sure to copy it somewhere safe.

Now that you create your credentials, let's have a look at the Template.

#### Parameters:

The parameters we will manipulate and inform are: 

Parameter         | Suggested value     | Description
:--------------- | :-------------      |:---------------------
**Subscription**  | Your subscription    |Select your Azure Student Subscription.
**Resource Group**| WebAppResourceGroup|      You can create a new resource group or choose from an existing one.
**Location**| The default location | Select the geographic location for your resource group. Your location choice can be any location listed, though it's often best to choose a location closest to your customer. The location cannot be changed once the bot is created.
**Web App Name** |*location*-*name*-*enviroment* i.e.:  uks-mybot-test  | The unique URL name of the bot. For example, if you name your bot uks-mybot-test, then your bot's URL will be http://uks-mybot-test.azurewebsites.net. The name must use alphanumeric and underscore characters only. There is a 35 character limit to this field. The App name cannot be changed once the bot is created. I personally like to add the location of the app into the name, and also the environment. That is the reason that my Web App Name is: uks-mybot-test
**App ID**| Your App ID | The App ID that you've created in the previous section.
**App Secret**| Complex Password| The secret that you've created in the previous section.


If you are new to **Azure Bot Service**, see:

- [Azure Bot Service](https://azure.microsoft.com/en-us/services/bot-service/).
- [Azure Bot Service Documentation](https://docs.microsoft.com/en-us/azure/bot-service/?view=azure-bot-service-4.0)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
