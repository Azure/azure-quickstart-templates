# Azure Web App with Git Hub Account

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/100-blank-template/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-github%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a><a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure4StudentQSTemplates%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-github%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a **simple Linux Web Application linked with GitHub Account**. This template is using, using the "S1" as the pricing tier for the hosting plan and the small instance size of the hosting plan.

### Prequisites:
#### Have a Git Hub Account

If you don't have yet a Git Hub account, you can create your account on [Git Hub](https://github.com/).

#### Parameters:

The parameters we will manipulate and inform are:

Parameter         | Suggested value     | Description
:--------------- | :-------------      |:---------------------
**siteName** |*location*-*name*-*enviroment* i.e.:  uks-mywebappgit-test  | The unique URL name of the WebApp. I recommend you to use the notation above, that helps to create a unique name for your Web Application. The name must use alphanumeric and underscore characters only. There is a 35 character limit to this field. The App name cannot be changed once the bot is created.
**repoURL**  | Git Repository URL     |The URL for the GitHub repository that contains the project to deploy.
**branch**  | master     |The branch of the GitHub repository to use.
**Resource Group**| simpleWebAppGit-RG|  That is the Resource Group you gonna need to deploy your resources.
**Location**| The default location | Select the geographic location for your resource group. Your location choice can be any location listed, though it's often best to choose a location closest to your customer. The location cannot be changed once the bot is created.
