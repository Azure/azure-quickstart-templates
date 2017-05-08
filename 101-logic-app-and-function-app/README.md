# Call an Azure Function from a Logic App

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-and-function-app%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-logic-app-and-function-app%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a Serverless app in Azure with Logic Apps and Functions.  The Logic App triggers on an HTTP POST, calls the Azure Function, and returns the response.

If you wish to open this in the Visual Studio Logic App designer, be sure to deploy once to any resource group, and set the `defaultValue` for the `functionAppName` to the deployed function app.  This will allow editing within the designer in Visual Studio.  The template can still be deployed to any resource group with any `functionAppName` later.
